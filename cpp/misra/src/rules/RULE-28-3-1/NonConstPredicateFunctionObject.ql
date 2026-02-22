/**
 * @id cpp/misra/non-const-predicate-function-object
 * @name RULE-28-3-1: Predicates shall not have persistent side effects
 * @description Much of the behavior of predicates is implementation defined, such as how and when
 *              it is invoked with which argument values, and if it is copied or moved. Therefore,
 *              predicate function objects should be declared const.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-28-3-1
 *       scope/system
 *       correctness
 *       maintainability
 *       portability
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.SideEffect
import codingstandards.cpp.types.Predicate

from MemberFunction callOperator, PredicateFunctionObject obj, Locatable usageSite
where
  not isExcluded([callOperator, usageSite],
    SideEffects6Package::nonConstPredicateFunctionObjectQuery()) and
  obj.getSubstitution().getASubstitutionSite() = usageSite and
  callOperator = obj.getCallOperator() and
  not callOperator instanceof ConstMemberFunction
select usageSite, "Predicate usage of $@ has $@", callOperator.getDeclaringType(),
  "callable object " + callOperator.getDeclaringType().getName(), callOperator,
  "non const operator()."
