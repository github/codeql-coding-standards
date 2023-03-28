/**
 * @id cpp/autosar/unchecked-range-domain-pole-errors
 * @name A0-4-4: Range, domain and pole errors shall be checked when using math functions
 * @description Range, domain or pole errors in math functions may return unexpected values, trigger
 *              floating-point exceptions or set unexpected error modes.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a0-4-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.uncheckedrangedomainpoleerrors.UncheckedRangeDomainPoleErrors

class UncheckedRangeDomainPoleErrorsQuery extends UncheckedRangeDomainPoleErrorsSharedQuery {
  UncheckedRangeDomainPoleErrorsQuery() {
    this = TypeRangesPackage::uncheckedRangeDomainPoleErrorsQuery()
  }
}
