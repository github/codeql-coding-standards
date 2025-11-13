/**
 * @id c/misra/initializer-lists-contain-persistent-side-effects
 * @name RULE-13-1: Initializer lists shall not contain persistent side effects
 * @description The order in which side effects occur during the evaluation of the expressions in an
 *              initializer list is unspecified and can result in unexpected program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-1
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/safety
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.sideeffect.Customizations

class CrementEffect extends LocalSideEffect::Range {
  CrementEffect() { this instanceof CrementOperation }
}

from AggregateLiteral initList, SideEffect effect
where
  not isExcluded(initList, SideEffects1Package::initializerListsContainPersistentSideEffectsQuery()) and
  (
    initList.(ArrayOrVectorAggregateLiteral).getAnElementExpr(_) = effect
    or
    initList.(ClassAggregateLiteral).getAFieldExpr(_) = effect
  )
select initList, "Initializer list constains persistent $@", effect, "side effect"
