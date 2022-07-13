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

from ContainerIteratorAccess it
where
  not isExcluded(it, IteratorsPackage::doNotUseAnAdditiveOperatorOnAnIteratorQuery()) and
  it.isAdditiveOperation() and
  not exists(RangeBasedForStmt fs | fs.getUpdate().getAChild*() = it) and
  // we get the neraby assignment
  not exists(STLContainer c, FunctionCall nearbyAssigningIteratorCall, FunctionCall guardCall |
    nearbyAssigningIteratorCall = it.getANearbyAssigningIteratorCall() and
    // we look for calls to size or end
    (guardCall = c.getACallToSize() or guardCall = c.getAnIteratorEndFunctionCall()) and
    // such that the call to size is before this
    // access
    guardCall = it.getAPredecessor*() and
    // and it uses the same qualifier as the one we were just assigned
    nearbyAssigningIteratorCall.getQualifier().(VariableAccess).getTarget() =
      guardCall.getQualifier().(VariableAccess).getTarget() and
    // and the size call we match must be after the assignment call
    nearbyAssigningIteratorCall.getASuccessor*() = guardCall
  )
select it, "Increment of iterator may overflow since its bounds are not checked."
