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

/**
 * any `.size()` check above our access
 */
predicate size_checked_above(ContainerIteratorAccess it, IteratorSource source) {
  exists(STLContainer c, FunctionCall guardCall |
    c.getACallToSize() = guardCall and
    guardCall = it.getAPredecessor*() and
    //make sure its the same container providing its size as giving the iterator
    globalValueNumber(guardCall.getQualifier()) = globalValueNumber(source.getQualifier()) and
    // and the size call we match must be after the assignment call
    source.getASuccessor*() = guardCall
  )
}

/**
 * some loop check exists like: `iterator != end`
 * where a relevant`.end()` call flowed into end
 */
predicate valid_end_bound_check(ContainerIteratorAccess it, IteratorSource source) {
  exists(STLContainer c, Loop l, ContainerIteratorAccess otherAccess, IteratorSource end |
    end = c.getAnIteratorEndFunctionCall() and
    //flow exists between end() and the loop condition
    DataFlow::localFlow(DataFlow::exprNode(end), DataFlow::exprNode(l.getCondition().getAChild())) and
    l.getCondition().getAChild() = otherAccess and
    //make sure its the same iterator being checked as incremented
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
  not size_compare_bounds_checked(source, it) and
  not valid_end_bound_check(it, source) and
  not size_checked_above(it, source)
select it, "Increment of iterator may overflow since its bounds are not checked."
