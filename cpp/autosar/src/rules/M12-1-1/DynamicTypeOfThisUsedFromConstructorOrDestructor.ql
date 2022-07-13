/**
 * @id cpp/autosar/dynamic-type-of-this-used-from-constructor-or-destructor
 * @name M12-1-1: An object's dynamic type shall not be used from the body of its constructor or destructor
 * @description The dynamic type of an object is undefined during construction or destruction and
 *              must not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m12-1-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

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

from DynamicTypeExpr expr, FunctionCall call, MemberFunction mf, string explanation
where
  not isExcluded(expr, InheritancePackage::dynamicTypeOfThisUsedFromConstructorOrDestructorQuery()) and
  (
    mf instanceof Constructor or
    mf instanceof Destructor
  ) and
  (
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
select expr, explanation, mf, mf.getQualifiedName()
