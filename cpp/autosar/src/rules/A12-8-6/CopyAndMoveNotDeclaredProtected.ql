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
    f instanceof MoveConstructor and
    if f.isCompilerGenerated()
    then constructorType = "Implicit move constructor"
    else constructorType = "Move constructor"
    or
    f instanceof CopyConstructor and
    if f.isCompilerGenerated()
    then constructorType = "Implicit copy constructor"
    else constructorType = "Copy constructor"
  )
}

predicate isInvalidAssignment(Operator f, string operatorType) {
  not f.isDeleted() and
  (
    f instanceof MoveAssignmentOperator and
    if f.isCompilerGenerated()
    then operatorType = "Implicit move assignment operator"
    else operatorType = "Move constructor"
    or
    f instanceof CopyAssignmentOperator and
    if f.isCompilerGenerated()
    then operatorType = "Implicit copy assignment operator"
    else operatorType = "Copy assignment operator"
  ) and
  not f.hasSpecifier("protected")
}

from BaseClass baseClass, MemberFunction mf, string type
where
  not isExcluded(mf, OperatorsPackage::copyAndMoveNotDeclaredProtectedQuery()) and
  (
    isInvalidConstructor(mf, type)
    or
    isInvalidAssignment(mf, type)
  ) and
  baseClass = mf.getDeclaringType()
// To avoid duplicate alerts due to inaccurate location information in the database we don't use the location of the base class.
// This for example happens if multiple copies of the same header file are present in the database.
select getDeclarationEntryInClassDeclaration(mf),
  type + " for base class '" + baseClass.getQualifiedName() +
    "' is not declared protected or deleted."
