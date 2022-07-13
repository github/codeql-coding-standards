/**
 * @id cpp/autosar/ordering-predicates-invariants
 * @name A25-4-1: Ordering predicates must be strictly weakly ordering
 * @description Providing an ordering predicate that is not strictly weak can result in unexpected
 *              behavior from containers and sorting functions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a25-4-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.orderingpredicatemustbestrictlyweak.OrderingPredicateMustBeStrictlyWeak

class OrderingPredicatesInvariantsQuery extends OrderingPredicateMustBeStrictlyWeakSharedQuery {
  OrderingPredicatesInvariantsQuery() {
    this = InvariantsPackage::orderingPredicatesInvariantsQuery()
  }
}
