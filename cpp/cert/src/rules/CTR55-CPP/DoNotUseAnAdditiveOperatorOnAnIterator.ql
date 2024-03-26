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
 * something like:
 * `end = begin() + size()`
 */
Expr calculatedEndCheck(AdditiveOperatorFunctionCall calc) {
  exists(
    ContainerAccessWithoutRangeCheck::ContainerSizeCall size,
    ContainerAccessWithoutRangeCheck::ContainerBeginCall begin
  |
    calc.getTarget().hasName("operator+") and
    DataFlow::localFlow(DataFlow::exprNode(size), DataFlow::exprNode(calc.getAChild*())) and
    DataFlow::localFlow(DataFlow::exprNode(begin), DataFlow::exprNode(calc.getAChild*())) and
    //make sure its the same container providing its size as giving the begin
    globalValueNumber(begin.getQualifier()) = globalValueNumber(size.getQualifier()) and
    result = begin.getQualifier()
  )
}

Expr validEndCheck(FunctionCall end) {
  end instanceof ContainerAccessWithoutRangeCheck::ContainerEndCall and
  result = end.getQualifier()
  or
  result = calculatedEndCheck(end)
}

/**
 * some guard exists like: `iterator != end`
 * where a relevant`.end()` call flowed into end
 */
predicate validEndBoundCheck(ContainerIteratorAccess it, IteratorSource source) {
  exists(
    FunctionCall end, BasicBlock b, GuardCondition l, ContainerIteratorAccess otherAccess,
    Expr qualifierToCheck
  |
    //sufficient end guard
    qualifierToCheck = validEndCheck(end) and
    //guard controls the access
    l.controls(b, _) and
    b.contains(it) and
    //guard is comprised of end check and an iterator access
    DataFlow::localFlow(DataFlow::exprNode(end), DataFlow::exprNode(l.getChild(_))) and
    l.getChild(_) = otherAccess and
    //make sure its the same iterator being checked in the guard as accessed
    otherAccess.getOwningContainer() = it.getOwningContainer() and
    //if its the end call itself (or its parts), make sure its the same container providing its end as giving the iterator
    globalValueNumber(qualifierToCheck) = globalValueNumber(source.getQualifier()) and
    // and the guard call we match must be after the assignment call (to avoid valid guards protecting new iterator accesses further down)
    source.getASuccessor*() = l
  )
}

from ContainerIteratorAccess it, IteratorSource source
where
  not isExcluded(it, IteratorsPackage::doNotUseAnAdditiveOperatorOnAnIteratorQuery()) and
  it.isAdditiveOperation() and
  not exists(RangeBasedForStmt fs | fs.getUpdate().getAChild*() = it) and
  source = it.getANearbyAssigningIteratorCall() and
  not validEndBoundCheck(it, source) and
  not sizeCompareBoundsChecked(source, it)
select it, "Increment of iterator may overflow since its bounds are not checked."
