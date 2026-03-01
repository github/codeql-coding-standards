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
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.SideEffect
import codingstandards.cpp.types.Predicate

from Locatable usageSite, Function f, SideEffect effect
where
  not isExcluded([usageSite, effect], SideEffects6Package::predicateWithPersistentSideEffectsQuery()) and
  effect = getAnExternalOrGlobalSideEffectInFunction(f) and
  not effect instanceof ConstructorFieldInit and
  (
    // Case 1: a function pointer used directly as a predicate argument
    exists(PredicateFunctionPointerUse use |
      use = usageSite and
      f = use.getTarget()
    )
    or
    // Case 2: a function object whose call operator has side effects
    exists(PredicateFunctionObject obj |
      usageSite = obj.getSubstitution().getASubstitutionSite() and
      f = obj.getCallOperator()
    )
  )
select usageSite, "Predicate $@ has a $@.", f, f.getName(), effect, "persistent side effect"
