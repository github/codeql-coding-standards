/**
 * @id cpp/misra/predicate-with-persistent-side-effects
 * @name RULE-28-3-1: Predicates shall not have persistent side effects
 * @description Much of the behavior of predicates is implementation defined, such as how and when
 *              it is invoked with which argument values, and if it is copied or moved. Therefore,
 *              persistent side effects in a predicate cannot be relied upon and should not occur.
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

predicate functionHasSideEffect(Function f) {
  hasExternalOrGlobalSideEffectInFunction(f)
}

predicate isPredicateObject(PredicateFunctionObject obj, PredicateType pred, Locatable usageSite, Function callOperator) {
  obj.getSubstitution().getASubstitutionSite() = usageSite and
  pred = obj.getPredicateType() and
  callOperator = obj.getCallOperator()
}

predicate isPredicateFunctionPointerUse(PredicateFunctionPointerUse predPtrUse, PredicateType pred, Function func) {
  pred = predPtrUse.getPredicateType() and
  func = predPtrUse.getTarget()
}

where
  not isExcluded(x, SideEffects6Package::predicateWithPersistentSideEffectsQuery()) and
select
