/**
 * @id cpp/misra/improperly-provided-special-member-functions-audit
 * @name RULE-15-0-1: Special member functions shall be provided appropriately, Audit
 * @description Audit: incorrect provision of special member functions can lead to unexpected or
 *              undefined behavior when objects of the class are copied, moved, or destroyed.
 * @kind problem
 * @precision low
 * @problem.severity warning
 * @tags external/misra/id/rule-15-0-1
 *       scope/single-translation-unit
 *       correctness
 *       audit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import AnalyzableClass

string missingKind(Class c) {
  not c.getAConstructor() instanceof MoveConstructor and
  result = "move constructor"
  or
  not c.getAMemberFunction() instanceof MoveAssignmentOperator and
  result = "move assignment operator"
  or
  not c.getAConstructor() instanceof CopyConstructor and
  result = "copy constructor"
  or
  not c.getAMemberFunction() instanceof CopyAssignmentOperator and
  result = "copy assignment operator"
  or
  not c.getAMemberFunction() instanceof Destructor and
  result = "destructor"
}

string missingKinds(Class c) { result = concat(missingKind(c), " and ") }

from Class c, string kinds
where
  not isExcluded(c, Classes3Package::improperlyProvidedSpecialMemberFunctionsAuditQuery()) and
  not c instanceof AnalyzableClass and
  not c.isPod() and
  kinds = missingKinds(c)
select c,
  "Class '" + c.getName() + "' is not analyzable because the " + kinds +
    " are not present in the CodeQL database."
