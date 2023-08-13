import cpp
import semmle.code.cpp.dataflow.DataFlow

// Local cached version of localExprFlow to avoid bad magic
cached
predicate localExprFlow(Expr source, Expr sink) { DataFlow::localExprFlow(source, sink) }

abstract class AutosarSmartPointer extends Class {
  ConstructorCall getAConstructorCall() {
    result =
      any(ConstructorCall cc |
        cc.getTargetType() = this and
        not cc.getEnclosingFunction().getDeclaringType() instanceof AutosarSmartPointer
      )
  }

  Type getOwnedObjectType() {
    result = this.(ClassTemplateInstantiation).getTemplateArgument(0).(Type).getUnderlyingType()
  }

  FunctionCall getAMakePointerCall() {
    result =
      any(Function f, FunctionCall fc |
        f.hasQualifiedName("std", ["make_unique", "make_shared"]) and
        fc = f.getACallToThisFunction() and
        fc.getExpectedReturnType().stripTopLevelSpecifiers() = this
      |
        fc
      )
  }

  FunctionCall getAGetCall() {
    result.getTarget().hasName("get") and
    result.getQualifier().getType().stripType() = this
  }

  FunctionCall getAnInitializerExpr() {
    result =
      any(FunctionCall fc |
        fc = getAMakePointerCall()
        or
        fc = getAConstructorCall()
      )
  }

  ConstructorCall getAConstructorCallWithExternalObjectConstruction() {
    result =
      any(ConstructorCall cc |
        cc = this.getAConstructorCall() and
        // exclude instantiation with a custom deleter
        cc.getNumberOfArguments() = 1 and
        // exclude compiler generated constructors, such as for member variables
        not cc.isCompilerGenerated() and
        // exclude arguments of this type
        not cc.getArgument(0).getFullyConverted().getType().stripType() instanceof
          AutosarSmartPointer
      )
  }

  FunctionCall getAResetCall() {
    result.getTarget().hasName("reset") and
    result.getQualifier().getType().stripType() = this
  }

  FunctionCall getAModifyingCall() {
    result.getTarget().hasName(["operator=", "reset", "swap"]) and
    result.getQualifier().getType().stripType() = this
  }
}

class AutosarUniquePointer extends AutosarSmartPointer {
  AutosarUniquePointer() { this.hasQualifiedName("std", "unique_ptr") }

  FunctionCall getAReleaseCall() {
    result.getTarget().hasName("release") and
    result.getQualifier().getType().stripType() = this
  }
}

class AutosarSharedPointer extends AutosarSmartPointer {
  AutosarSharedPointer() { this.hasQualifiedName("std", "shared_ptr") }
}

class AutosarWeakPointer extends AutosarSmartPointer {
  AutosarWeakPointer() { this.hasQualifiedName("std", "weak_ptr") }
}

class DefinedSmartPointerParameter extends Parameter {
  DefinedSmartPointerParameter() {
    this.getType().stripType() instanceof AutosarSmartPointer and
    exists(Function f | f = this.getFunction() |
      f.hasDefinition() and
      not f.isCompilerGenerated() and
      exists(f.getBlock())
    )
  }
}

/**
 * A release member function for an AutosarSmartPointerType
 */
class AutosarSmartPointerReleaseMemberFunction extends MemberFunction, TaintFunction {
  AutosarSmartPointerReleaseMemberFunction() {
    this.hasName("release") and
    this.getDeclaringType() instanceof AutosarSmartPointer
  }

  override predicate hasTaintFlow(FunctionInput input, FunctionOutput output) {
    input.isQualifierObject() and
    output.isReturnValue()
  }
}

Expr varOwnershipSharingExpr(Type t, Function f) {
  result.getEnclosingFunction() = f and
  result.getUnderlyingType() = t and
  (
    // all shared_ptr return statement expressions or function call
    // arguments, including compiler-generated calls to constructors
    exists(ReturnStmt ret | result = ret.getExpr())
    or
    exists(FunctionCall fc | result = fc.getAnArgument())
    or
    // all assignments of a shared_ptr to a member, global, or namespace variable
    exists(AssignExpr ae, Variable var |
      result = ae.getRValue() and
      (
        ae.getLValue().(VariableAccess).getTarget() = var and
        (var instanceof GlobalOrNamespaceVariable or var instanceof MemberVariable)
        or
        // include overloaded array expressions (such as in std::map)
        ae.getLValue() instanceof OverloadedArrayExpr
        or
        // as well as pointer dereference expressions
        ae.getLValue() instanceof PointerDereferenceExpr
      )
    )
  )
}

predicate allocationFlowsToOwnershipSharingExpr(AllocationExpr ae) {
  localExprFlow(ae, varOwnershipSharingExpr(any(PointerType t), ae.getEnclosingFunction()))
}

predicate fieldFlowsToOwnershipSharingExpr(Field mv) {
  // public fields accessed by non-member functions can be considered shared
  mv.isPublic() and
  not mv.getAnAccess().getEnclosingFunction().getDeclaringType().getABaseClass*() =
    mv.getDeclaringType()
  or
  // check if any method accesses the field and flows to an ownership sharing expr
  exists(MemberFunction mf, VariableAccess va |
    mv.getDeclaringType() = mf.getDeclaringType().getABaseClass*() and
    not mf instanceof Constructor and
    not mf instanceof Destructor and
    va.getEnclosingFunction() = mf and
    va.getTarget() = mv and
    localExprFlow(va, varOwnershipSharingExpr(any(PointerType t), mf))
  )
}
