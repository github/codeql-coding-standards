/**
 * @id cpp/autosar/copy-and-move-not-declared-protected
 * @name A12-8-6: Copy and move constructors and copy assignment and move assignment operators shall be declared
 * @description Copy and move constructors and copy assignment and move assignment operators shall
 *              be declared protected or defined '=delete' in base class.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a12-8-6
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class

predicate isInvalidConstructor(Constructor f, string constructorType) {
  not f.isDeleted() and
  not f.isProtected() and
  (
    f instanceof MoveConstructor and constructorType = "Move constructor"
    or
    f instanceof CopyConstructor and constructorType = "Copy constructor"
  )
}

predicate isInvalidAssignment(Operator f, string operatorType) {
  not f.isDeleted() and
  (
    f instanceof CopyAssignmentOperator and operatorType = "Copy assignment operator"
    or
    f instanceof MoveAssignmentOperator and operatorType = "Move assignment operator"
  ) and
  not f.hasSpecifier("protected")
}

from MemberFunction mf, string type, string baseReason
where
  not isExcluded(mf, OperatorsPackage::copyAndMoveNotDeclaredProtectedQuery()) and
  (
    isInvalidConstructor(mf, type)
    or
    isInvalidAssignment(mf, type)
  ) and
  isPossibleBaseClass(mf.getDeclaringType(), baseReason)
select getDeclarationEntryInClassDeclaration(mf),
  type + " for base class " + mf.getDeclaringType().getQualifiedName() + " (" + baseReason +
    ") is not declared protected or deleted."
