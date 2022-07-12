/**
 * @id cpp/cert/provide-a-valid-ordering-predicate
 * @name CTR57-CPP: Provide a valid ordering predicate
 * @description Providing an ordering predicate that is not strictly weak can result in unexpected
 *              behavior from containers and sorting functions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/ctr57-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.orderingpredicatemustbestrictlyweak.OrderingPredicateMustBeStrictlyWeak

class ProvideAValidOrderingPredicateQuery extends OrderingPredicateMustBeStrictlyWeakSharedQuery {
  ProvideAValidOrderingPredicateQuery() {
    this = InvariantsPackage::provideAValidOrderingPredicateQuery()
  }
}
