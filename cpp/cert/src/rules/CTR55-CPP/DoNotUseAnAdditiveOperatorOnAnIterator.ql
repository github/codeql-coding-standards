/**
 * @id cpp/cert/do-not-use-an-additive-operator-on-an-iterator
 * @name CTR55-CPP: Do not use an additive operator on an iterator if the result would overflow
 * @description Using an additive operator on an iterator without proper bounds checks can result in
 *              an overflow.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/ctr55-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Iterators
import semmle.code.cpp.controlflow.Dominance

/**
 * any `.size()` check above our access
 */
predicate sizeCheckedAbove(ContainerIteratorAccess it, IteratorSource source) {
  exists(ContainerAccessWithoutRangeCheck::ContainerSizeCall guardCall |
    strictlyDominates(guardCall, it) and
    //make sure its the same container providing its size as giving the iterator
    globalValueNumber(guardCall.getQualifier()) = globalValueNumber(source.getQualifier()) and
    // and the size call we match must be after the assignment call
    source.getASuccessor*() = guardCall
  )
}

/**
 * some guard exists like: `iterator != end`
 * where a relevant`.end()` call flowed into end
 */
predicate validEndBoundCheck(ContainerIteratorAccess it, IteratorSource source) {
  exists(
    STLContainer c, BasicBlock b, GuardCondition l, ContainerIteratorAccess otherAccess,
    IteratorSource end
  |
    end = c.getAnIteratorEndFunctionCall() and
    //guard controls the access
    l.controls(b, _) and
    b.contains(it) and
    //guard is comprised of (anything flowing to) end check and an iterator access
    DataFlow::localFlow(DataFlow::exprNode(end), DataFlow::exprNode(l.getChild(_))) and
    l.getChild(_) = otherAccess and
    //make sure its the same iterator being checked in the guard as accessed
    otherAccess.getOwningContainer() = it.getOwningContainer() and
    //make sure its the same container providing its end as giving the iterator
    globalValueNumber(end.getQualifier()) = globalValueNumber(source.getQualifier())
  )
}

from ContainerIteratorAccess it, IteratorSource source
where
  not isExcluded(it, IteratorsPackage::doNotUseAnAdditiveOperatorOnAnIteratorQuery()) and
  it.isAdditiveOperation() and
  not exists(RangeBasedForStmt fs | fs.getUpdate().getAChild*() = it) and
  source = it.getANearbyAssigningIteratorCall() and
  not sizeCompareBoundsChecked(source, it) and
  not validEndBoundCheck(it, source) and
  not sizeCheckedAbove(it, source)
select it, "Increment of iterator may overflow since its bounds are not checked."
