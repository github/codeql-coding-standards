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

predicate isInvalidConstructor(Constructor f, string constructorType, string missingAction) {
  not f.isDeleted() and
  not f.isProtected() and
  (
    f instanceof MoveConstructor and
    if f.isCompilerGenerated()
    then constructorType = "Implicit move constructor" and missingAction = "deleted"
    else (constructorType = "Move constructor" and missingAction = "protected")
    or
    f instanceof CopyConstructor and
    if f.isCompilerGenerated()
    then constructorType = "Implicit copy constructor" and missingAction = "deleted"
    else (constructorType = "Copy constructor" and missingAction = "protected")
  )
}

predicate isInvalidAssignment(Operator f, string operatorType, string missingAction) {
  not f.isDeleted() and
  (
    f instanceof MoveAssignmentOperator and
    if f.isCompilerGenerated()
    then operatorType = "Implicit move assignment operator" and missingAction = "deleted"
    else (operatorType = "Move assignment operator" and missingAction = "protected")
    or
    f instanceof CopyAssignmentOperator and
    if f.isCompilerGenerated()
    then operatorType = "Implicit copy assignment operator" and missingAction = "deleted"
    else (operatorType = "Copy assignment operator" and missingAction = "protected")
  ) and
  not f.hasSpecifier("protected")
}

from BaseClass baseClass, MemberFunction mf, string type, string missingAction
where
  not isExcluded(mf, OperatorsPackage::copyAndMoveNotDeclaredProtectedQuery()) and
  (
    isInvalidConstructor(mf, type, missingAction)
    or
    isInvalidAssignment(mf, type, missingAction)
  ) and
  baseClass = mf.getDeclaringType()
// To avoid duplicate alerts due to inaccurate location information in the database we don't use the location of the base class.
// This for example happens if multiple copies of the same header file are present in the database.
select getDeclarationEntryInClassDeclaration(mf),
  type + " for base class '" + baseClass.getQualifiedName() +
    "' is not declared "+ missingAction +"."
