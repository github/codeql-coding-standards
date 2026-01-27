/**
 * @id cpp/misra/invalid-signature-for-special-member-function
 * @name RULE-15-0-2: User-provided copy and move member functions of a class should have appropriate signatures
 * @description Proper implementations of copy and move constructors and assignment operators ensure
 *              that resources are managed correctly.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-15-0-2
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codeql.util.Boolean

pragma[inline]
predicate checkSignature(
  MemberFunction f, Boolean noexcept, Boolean lvalueQualified, Boolean rvalueRef, string err
) {
  f.getNumberOfParameters() > 1 and
  err = "too many parameters"
  or
  noexcept = true and
  not f.isNoExcept() and
  err = "should be noexcept"
  or
  lvalueQualified = true and
  not f.isLValueRefQualified() and
  err = "should be lvalue-qualified"
  or
  lvalueQualified = false and
  f.isLValueRefQualified() and
  err = "should not be lvalue-qualified"
  or
  rvalueRef = true and
  not isRvalueRefX(f.getParameter(0).getType(), f.getDeclaringType()) and
  err = "should take rvalue reference to class or struct type"
  or
  rvalueRef = false and
  not isConstRefX(f.getParameter(0).getType(), f.getDeclaringType()) and
  err = "should take const reference to class or struct type"
  or
  f.isVirtual() and
  err = "should not be virtual"
  or
  not f instanceof Constructor and
  not f.getType().(LValueReferenceType).getBaseType() = f.getDeclaringType() and
  not f.getType() instanceof VoidType and
  err = "should return void or lvalue reference to class or struct type"
  or
  not f instanceof Constructor and
  f.isExplicit() and
  err = "should not be explicit"
}

predicate isRvalueRefX(Type t, Class x) {
  // X &&
  t.(RValueReferenceType).getBaseType() = x
}

predicate isConstRefX(Type t, Class x) {
  exists(SpecifiedType st |
    // X const &
    st = t.(LValueReferenceType).getBaseType() and
    st.getSpecifierString() = "const" and
    st.getBaseType() = x
    or
    // const X &
    st = t and
    st.getSpecifierString() = "const" and
    st.getBaseType().(LValueReferenceType).getBaseType() = x
  )
}

from MemberFunction f, string err, string prefix
where
  not isExcluded(f, Classes2Package::invalidSignatureForSpecialMemberFunctionQuery()) and
  not f.isDeleted() and
  not f.isDefaulted() and
  not f.isCompilerGenerated() and
  (
    f instanceof CopyConstructor and
    prefix = "Copy constructor" and
    checkSignature(f, false, false, false, err)
    or
    f instanceof MoveConstructor and
    prefix = "Move constructor" and
    checkSignature(f, true, false, true, err)
    or
    f instanceof CopyAssignmentOperator and
    prefix = "Copy assignment operator" and
    checkSignature(f, false, true, false, err)
    or
    f instanceof MoveAssignmentOperator and
    prefix = "Move assignment operator" and
    checkSignature(f, true, true, true, err)
  )
select f, prefix + " on type $@ " + err + ".", f.getDeclaringType(), f.getDeclaringType().getName()
