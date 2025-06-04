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
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Iterators
import semmle.code.cpp.controlflow.Dominance

/**
 * Models a call to an iterator's `operator+`
 */
class AdditionOperatorFunctionCall extends AdditiveOperatorFunctionCall {
  AdditionOperatorFunctionCall() { this.getTarget().hasName("operator+") }
}

/**
 *  There exists a calculation for the reference one passed the end of some container
 *  An example derivation is:
 *     `end = begin() + size()`
 */
Expr getDerivedReferenceToOnePassedTheEndElement(Expr containerReference) {
  exists(
    ContainerAccessWithoutRangeCheck::ContainerSizeCall size,
    ContainerAccessWithoutRangeCheck::ContainerBeginCall begin, AdditionOperatorFunctionCall calc
  |
    result = calc
  |
    DataFlow::localFlow(DataFlow::exprNode(size), DataFlow::exprNode(calc.getAChild+())) and
    DataFlow::localFlow(DataFlow::exprNode(begin), DataFlow::exprNode(calc.getAChild+())) and
    //make sure its the same container providing its size as giving the begin
    globalValueNumber(begin.getQualifier()) = globalValueNumber(size.getQualifier()) and
    containerReference = begin.getQualifier()
  )
}

/**
 * a wrapper predicate for a couple of types of permitted end bounds checks
 */
Expr getReferenceToOnePassedTheEndElement(Expr containerReference) {
  //a container end access - v.end()
  result instanceof ContainerAccessWithoutRangeCheck::ContainerEndCall and
  containerReference = result.(FunctionCall).getQualifier()
  or
  result = getDerivedReferenceToOnePassedTheEndElement(containerReference)
}

/**
 * some guard exists like: `iterator != end`
 * where a relevant`.end()` call flowed into end
 */
predicate isUpperBoundEndCheckedIteratorAccess(IteratorSource source, ContainerIteratorAccess it) {
  exists(
    Expr referenceToOnePassedTheEndElement, BasicBlock basicBlockOfIteratorAccess,
    GuardCondition upperBoundCheck, ContainerIteratorAccess checkedIteratorAccess,
    Expr containerReferenceFromEndGuard
  |
    //sufficient end guard
    referenceToOnePassedTheEndElement =
      getReferenceToOnePassedTheEndElement(containerReferenceFromEndGuard) and
    //guard controls the access
    upperBoundCheck.controls(basicBlockOfIteratorAccess, _) and
    basicBlockOfIteratorAccess.contains(it) and
    //guard is comprised of end check and an iterator access
    DataFlow::localFlow(DataFlow::exprNode(referenceToOnePassedTheEndElement),
      DataFlow::exprNode(upperBoundCheck.getChild(_))) and
    upperBoundCheck.getChild(_) = checkedIteratorAccess and
    //make sure its the same iterator being checked in the guard as accessed
    checkedIteratorAccess.getOwningContainer() = it.getOwningContainer() and
    //if its the end call itself (or its parts), make sure its the same container providing its end as giving the iterator
    globalValueNumber(containerReferenceFromEndGuard) = globalValueNumber(source.getQualifier()) and
    // and the guard call we match must be after the assignment call (to avoid valid guards protecting new iterator accesses further down)
    source.getASuccessor*() = upperBoundCheck
  )
}

from ContainerIteratorAccess it, IteratorSource source
where
  not isExcluded(it, IteratorsPackage::doNotUseAnAdditiveOperatorOnAnIteratorQuery()) and
  it.isAdditiveOperation() and
  not exists(RangeBasedForStmt fs | fs.getUpdate().getAChild*() = it) and
  source = it.getANearbyAssigningIteratorCall() and
  not isUpperBoundEndCheckedIteratorAccess(source, it) and
  not sizeCompareBoundsChecked(source, it)
select it, "Increment of iterator may overflow since its bounds are not checked."
