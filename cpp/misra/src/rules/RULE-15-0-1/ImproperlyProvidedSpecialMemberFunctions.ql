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

predicate unmovable(AnalyzableClass c) {
  not c.moveConstructible() and
  not c.moveAssignable() and
  not c.copyConstructible() and
  not c.copyAssignable()
}

predicate isValidCategory(AnalyzableClass c) {
  isCopyEnabled(c) or
  isMoveOnly(c) or
  unmovable(c)
}

predicate violatesCustomizedDestructorRequirements(AnalyzableClass c, string reason) {
  c.isCustomized(TDestructor()) and
  (
    c.moveConstructible() and
    not c.isCustomized(TMoveConstructor()) and
    reason = "Move constructor is not customized"
    or
    c.moveAssignable() and
    not c.isCustomized(TMoveAssignmentOperator()) and
    reason = "Move assignment operator is not customized"
    or
    c.copyConstructible() and
    not c.isCustomized(TCopyConstructor()) and
    reason = "Copy constructor is not customized"
    or
    c.copyAssignable() and
    not c.isCustomized(TCopyAssignmentOperator()) and
    reason = "Copy assignment operator is not customized"
  )
}

predicate violatesInheritanceRequirements(AnalyzableClass c) {
  exists(ClassDerivation d |
    d.getBaseClass() = c and
    d.hasSpecifier("public")
  ) and
  (
    isMoveOnly(c) and
    c.getDestructor().isPublic() and
    c.getDestructor().isVirtual()
    or
    c.getDestructor().isProtected() and
    not c.getDestructor().isVirtual()
  )
}

from AnalyzableClass c, string message
where
  not isExcluded(c, Classes3Package::improperlyProvidedSpecialMemberFunctionsQuery()) and
  (
    not isValidCategory(c) and
    message = "Class does not fall into a valid category (unmovable, move-only, or copy-enabled)."
    or
    violatesCustomizedDestructorRequirements(c, message)
    or
    violatesInheritanceRequirements(c) and
    message = "Class violates inheritance requirements for special member functions."
  )
select c, message
