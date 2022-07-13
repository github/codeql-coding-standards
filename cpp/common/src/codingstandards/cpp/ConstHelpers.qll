/**
 * provides a library for reasoning about const qualified objects
 */

import cpp
import codingstandards.cpp.SideEffect
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.FunctionParameter

/** A variable that can be modified (both the pointer and object pointed to if pointer type) */
class MutableVariable extends Variable {
  MutableVariable() {
    not this.isConstexpr() and
    //for pointer types , this means const int * const only
    not this.getUnderlyingType().isDeeplyConst()
  }
}

/**
 * A pointer or reference that can be modified
 */
class MutablePointerOrReferenceVariable extends MutableVariable {
  MutablePointerOrReferenceVariable() {
    (
      this.getUnspecifiedType() instanceof PointerType or
      this.getUnspecifiedType() instanceof ReferenceType
    )
  }
}

/**
 * `PointerType` or `ReferenceType` `Parameter`s
 * that refer to nonconst objects
 * belonging to any `Function` that is not `main`
 */
class NonConstPointerorReferenceParameter extends FunctionParameter {
  NonConstPointerorReferenceParameter() {
    this instanceof AccessedParameter and
    (
      this.getType().(DerivedType).getBaseType*() instanceof PointerType or
      this.getType().(DerivedType).getBaseType*() instanceof ReferenceType
    ) and
    not this.getType().(DerivedType).getBaseType+().isConst() and
    not this.getFunction() instanceof MainFunction
  }
}

/**
 * Non-const T& `Parameter`s to `Function`s
 */
class NonConstReferenceParameter extends Parameter {
  NonConstReferenceParameter() {
    // T&
    this.getType() instanceof LValueReferenceType and
    //underlying type is non-const
    not this.getType().(DerivedType).getBaseType+().isConst()
  }
}

/**
 * Non-const T* `Parameter`s to `Function`s
 * DOES NOT INCLUDE nonconst T* const
 * as those are `DerivedType` not `PointerType`
 */
class NonConstPointerParameter extends Parameter {
  NonConstPointerParameter() {
    // T*
    this.getType() instanceof PointerType and
    //underlying type is non-const
    not this.getType().(DerivedType).getBaseType+().isConst()
  }
}

//direct and indirect modification via VariableEffect
predicate isNotDirectlyModified(Variable v) { not exists(VariableEffect e | e.getTarget() = v) }

class FunctionCallToNonConst extends FunctionCall {
  FunctionCallToNonConst() { not this.getTarget().hasSpecifier("const") }
}

class NonConstNonLocalScopeVariable extends Variable {
  NonConstNonLocalScopeVariable() {
    not this instanceof LocalScopeVariable and
    not this.getType().isDeeplyConst()
  }
}

/**
 * `FunctionCall`s for `Function`s that have at least one
 * nonconst `Parameter`
 */
class FunctionCallWithAtLeastOneNonConstParam extends FunctionCall {
  FunctionCallWithAtLeastOneNonConstParam() {
    exists(Parameter p |
      this.getTarget().getAParameter() = p and
      not p.isConst()
    )
  }
}

//non-const method called on the object
//only makes sense for pointer/reference types
predicate notUsedAsQualifierForNonConst(Variable v) {
  not exists(FunctionCallToNonConst fcn | fcn.getQualifier() = v.getAnAccess())
}

//returned from its nonconst function
//only makes sense for pointer/reference types
predicate notReturnedFromNonConstFunction(NonConstPointerorReferenceParameter v) {
  not exists(ReturnStmt ret |
    ret.getEnclosingFunction() = v.getFunction() and
    not v.getFunction().getType().isConst() and
    ret.getExpr() = v.getAnAccess()
  )
}

//not passed as an argument to a non-const parameter
predicate notPassedAsArgToNonConstParam(Variable v) {
  not exists(FunctionCallWithAtLeastOneNonConstParam fc, int i |
    fc.getArgument(i) = v.getAnAccess() and
    not fc.getTarget().getParameter(i).isConst()
  )
}

//assigned to a nonlocal nonconst variable
predicate notAssignedToNonLocalNonConst(Variable v) {
  not exists(NonConstNonLocalScopeVariable otherV |
    DataFlow::localExprFlow(v.getAnAccess(), otherV.getAnAssignedValue())
  )
}
