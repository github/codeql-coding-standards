/**
 * @id cpp/cert/use-valid-iterator-ranges
 * @name CTR53-CPP: Use valid iterator ranges
 * @description Relying on the incorrect bounds of iterators can lead to inconsistent program
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/ctr53-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Iterators

predicate startEndArgumentsDoNotPointToTheSameContainer(
  IteratorRangeFunctionCall fc, Expr arg, string reason
) {
  arg = fc.getAStartRangeFunctionCallArgument() and
  not exists(STLContainer stl |
    DataFlow::localFlow(DataFlow::exprNode(stl.getAnIteratorBeginFunctionCall()),
      DataFlow::exprNode(arg))
  ) and
  reason = "The $@ of iterator range function does not point to the start of an iterator."
  or
  arg = fc.getAEndRangeFunctionCallArgument() and
  not exists(STLContainer stl |
    DataFlow::localFlow(DataFlow::exprNode(stl.getAnIteratorEndFunctionCall()),
      DataFlow::exprNode(arg))
  ) and
  reason = "The $@ of iterator range function does not point to the end of an iterator."
}

predicate startEndArgumentsDoNotPointToSameIterator(
  IteratorRangeFunctionCall fc, Expr arg, string reason
) {
  exists(Expr start, Expr end, IteratorSource startSource, IteratorSource endSource |
    // Start with the actual parameters to the range function (pairwise)
    fc.getAStartEndRangeFunctionCallArgumentPair(start, end) and
    // get the possible sources that create iterators
    startSource = any(STLContainer c).getAnIteratorFunctionCall() and
    endSource = any(STLContainer c).getAnIteratorFunctionCall() and
    // and get those that flow into this argument
    startSource.sourceFor(start) and
    endSource.sourceFor(end) and
    // and flag ones where the owner is not the same
    not startSource.getOwner() = endSource.getOwner() and
    arg = start and
    reason =
      "The start range $@ of iterator range function does not point to the same container as its corresponding end argument."
  )
}

from IteratorRangeFunctionCall fc, string reason, Expr arg
where
  not isExcluded(fc, IteratorsPackage::useValidIteratorRangesQuery()) and
  (
    // 1) Require iterators in the range are pointing to the same container.
    startEndArgumentsDoNotPointToSameIterator(fc, arg, reason)
    or
    // 2) That there exists flows into the start/end arguments that are not in fact
    //    start/end iterators.
    startEndArgumentsDoNotPointToTheSameContainer(fc, arg, reason)
    // 3) And the iterators are not invalidated. This functionality is a requirement
    //    of CTR51-CPP and A23-0-2 and it is addressed by those queries.
  )
select fc, reason, arg, "argument"
