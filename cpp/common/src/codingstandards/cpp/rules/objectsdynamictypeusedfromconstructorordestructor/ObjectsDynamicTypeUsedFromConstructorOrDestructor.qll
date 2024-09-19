/**
 * Provides a library with a `problems` predicate for the following issue:
 * An object’s dynamic type shall not be used from within its constructor or
 * destructor.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ObjectsDynamicTypeUsedFromConstructorOrDestructorSharedQuery extends Query { }

Query getQuery() { result instanceof ObjectsDynamicTypeUsedFromConstructorOrDestructorSharedQuery }

predicate thisCall(FunctionCall c) {
  c.getQualifier() instanceof ThisExpr or
  c.getQualifier().(PointerDereferenceExpr).getChild(0) instanceof ThisExpr
}

predicate virtualThisCall(FunctionCall c, Function overridingFunction) {
  c.isVirtual() and
  thisCall(c) and
  overridingFunction = c.getTarget().(VirtualFunction).getAnOverridingFunction()
}

class DynamicTypeExpr extends Expr {
  DynamicTypeExpr() {
    this instanceof TypeidOperator and
    this.getEnclosingFunction().getDeclaringType().isPolymorphic()
    or
    this instanceof DynamicCast
    or
    virtualThisCall(this.(FunctionCall), _)
  }
}

/*
 * Catch most cases: go into functions in the same class, but only catch direct
 * references to "this".
 */

predicate nonVirtualMemberFunction(MemberFunction mf, Class c) {
  mf = c.getAMemberFunction() and
  not mf instanceof Constructor and
  not mf instanceof Destructor and
  not mf.isVirtual()
}

predicate callFromNonVirtual(MemberFunction source, Class c, MemberFunction targ) {
  exists(FunctionCall fc |
    fc.getEnclosingFunction() = source and fc.getTarget() = targ and thisCall(fc)
  ) and
  targ = c.getAMemberFunction() and
  nonVirtualMemberFunction(source, c)
}

predicate indirectlyInvokesDynamicTypeExpr(MemberFunction caller, DynamicTypeExpr target) {
  target =
    any(DynamicTypeExpr expr |
      expr.getEnclosingFunction() = caller and
      nonVirtualMemberFunction(caller, caller.getDeclaringType())
    )
  or
  exists(MemberFunction mid |
    indirectlyInvokesDynamicTypeExpr(mid, target) and
    callFromNonVirtual(caller, caller.getDeclaringType(), mid)
  )
}

query predicate problems(
  DynamicTypeExpr expr, string explanation, MemberFunction mf, string mf_string
) {
  not isExcluded(expr, getQuery()) and
  (
    mf instanceof Constructor or
    mf instanceof Destructor
  ) and
  mf_string = mf.getQualifiedName() and
  exists(FunctionCall call |
    mf = expr.getEnclosingFunction() and
    explanation = "$@ uses the dynamic type of its own object."
    or
    mf != expr.getEnclosingFunction() and
    mf = call.getEnclosingFunction() and
    thisCall(call) and
    indirectlyInvokesDynamicTypeExpr(call.getTarget(), expr) and
    explanation =
      "$@ calls " + call.getTarget().getQualifiedName() +
        ", which uses the dynamic type of its own object."
  )
}
