/**
 * @id cpp/misra/improperly-provided-special-member-functions
 * @name RULE-15-0-1: Special member functions shall be provided appropriately
 * @description Incorrect provision of special member functions can lead to unexpected or undefined
 *              behavior when objects of the class are copied, moved, or destroyed.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/misra/id/rule-15-0-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import AnalyzableClass

predicate isCopyEnabled(AnalyzableClass c) {
  c.moveConstructible() and
  not c.moveAssignable() and
  c.copyConstructible() and
  not c.copyAssignable()
  or
  c.moveConstructible() and
  c.moveAssignable() and
  c.copyConstructible() and
  c.copyAssignable()
}

predicate isMoveOnly(AnalyzableClass c) {
  c.moveConstructible() and
  not c.moveAssignable() and
  not c.copyConstructible() and
  not c.copyAssignable()
  or
  c.moveConstructible() and
  c.moveAssignable() and
  not c.copyConstructible() and
  not c.copyAssignable()
}

predicate isUnmovable(AnalyzableClass c) {
  not c.moveConstructible() and
  not c.moveAssignable() and
  not c.copyConstructible() and
  not c.copyAssignable()
}

predicate isValidCategory(AnalyzableClass c) {
  isCopyEnabled(c) or
  isMoveOnly(c) or
  isUnmovable(c)
}

string specialMemberName(TSpecialMember f) {
  f = TCopyConstructor() and result = "copy constructor"
  or
  f = TMoveConstructor() and result = "move constructor"
  or
  f = TCopyAssignmentOperator() and result = "copy assignment operator"
  or
  f = TMoveAssignmentOperator() and result = "move assignment operator"
}

predicate violatesCustomizedMoveOrCopyRequirements(AnalyzableClass c, string reason) {
  not c.isCustomized(TDestructor()) and
  exists(string concatenated |
    concatenated =
      strictconcat(TSpecialMember f |
        not f = TDestructor() and
        c.isCustomized(f)
      |
        specialMemberName(f), ", "
      ) and
    reason = "has customized " + concatenated + ", but does not customize the destructor."
  )
}

private predicate undeclaredMoveException(AnalyzableClass c) {
  // A copy-enabled class may have an undeclared move constructor.
  isCopyEnabled(c) and
  not c.moveAssignable() and
  not c.declaresMoveConstructor()
  or
  // A copy-assignable class may leave both move operations undeclared.
  isCopyEnabled(c) and
  c.moveAssignable() and
  not c.declaresMoveConstructor() and
  not c.declaresMoveAssignmentOperator()
}

predicate violatesCustomizedDestructorRequirements(AnalyzableClass c, string reason) {
  c.isCustomized(TDestructor()) and
  (
    c.moveConstructible() and
    not c.isCustomized(TMoveConstructor()) and
    not undeclaredMoveException(c) and
    reason = "has customized the destructor, but does not customize the move constructor."
    or
    c.moveAssignable() and
    not undeclaredMoveException(c) and
    not c.isCustomized(TMoveAssignmentOperator()) and
    reason = "has customized the destructor, but does not customize the move assignment operator."
    or
    c.copyConstructible() and
    not c.isCustomized(TCopyConstructor()) and
    reason = "has customized the destructor, but does not customize the copy constructor."
    or
    c.copyAssignable() and
    not c.isCustomized(TCopyAssignmentOperator()) and
    reason = "has customized the destructor, but does not customize the copy assignment operator."
  )
}

predicate isPublicBase(AnalyzableClass c) {
  exists(ClassDerivation d |
    d.getBaseClass() = c and
    d.hasSpecifier("public")
  )
}

predicate satisfiesInheritanceRequirements(AnalyzableClass c) {
  not isPublicBase(c)
  or
  isUnmovable(c) and
  c.getDestructor().isPublic() and
  c.getDestructor().isVirtual()
  or
  c.getDestructor().isProtected() and
  not c.getDestructor().isVirtual()
}

from AnalyzableClass c, string message
where
  not isExcluded(c, Classes3Package::improperlyProvidedSpecialMemberFunctionsQuery()) and
  (
    not isValidCategory(c) and
    message = "does not fall into a valid category (isUnmovable, move-only, or copy-enabled)."
    or
    violatesCustomizedMoveOrCopyRequirements(c, message)
    or
    violatesCustomizedDestructorRequirements(c, message)
    or
    not satisfiesInheritanceRequirements(c) and
    message = "violates inheritance requirements for special member functions."
  )
select c, "Class '" + c.getName() + "' " + message
