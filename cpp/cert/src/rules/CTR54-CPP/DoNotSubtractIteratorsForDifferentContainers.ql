/**
 * @id cpp/cert/do-not-subtract-iterators-for-different-containers
 * @name CTR54-CPP: Do not subtract iterators that do not refer to the same container
 * @description Subtracting iterators that do not refer to the same container can cause unreliable
 *              program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/ctr54-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p8
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Iterators

/** Models the subtraction operator */
class SubtractionOperator extends Function {
  SubtractionOperator() { getName() = "operator-" }
}

/** Models a call to the subtraction operator */
class SubtractionOperatorFunctionCall extends FunctionCall {
  SubtractionOperatorFunctionCall() { getTarget() instanceof SubtractionOperator }
}

/*
 * Many of the concerns of this query are addressed by aspects of other queries.
 * For example, the rules of the `Pointers` package address issues of
 * subtracting incompatible pointers. Additionally, CTR53-CPP detects errors
 * using functions that operator on iterators as well as provides specific
 * models for unique cases such as `std::lexicographical_compare` via
 * `IteratorRangeModel` and `IteratorRangeFunctionCall`.
 *
 * This query covers the remaining cases of iterators used in expressions where
 * the iterator may have not been created from the same containers.
 */

from SubtractionOperatorFunctionCall fc
where
  not isExcluded(fc, IteratorsPackage::doNotSubtractIteratorsForDifferentContainersQuery()) and
  exists(IteratorSource startSource, IteratorSource endSource |
    // get the possible sources that create iterators
    startSource = any(STLContainer c).getAnIteratorFunctionCall() and
    endSource = any(STLContainer c).getAnIteratorFunctionCall() and
    // look at sources that flow into this operator's argument
    startSource.sourceFor(fc.getArgument(0)) and
    endSource.sourceFor(fc.getArgument(1)) and
    // flags ones where the owner is not the same
    not startSource.getOwner() = endSource.getOwner()
  )
select fc, "Subtraction of iterators that do not refer to the same container."
