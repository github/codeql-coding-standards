/**
 * @id c/cert/unchecked-range-domain-pole-errors
 * @name FLP32-C: Prevent or detect domain and range errors in math functions
 * @description Range, domain or pole errors in math functions may return unexpected values, trigger
 *              floating-point exceptions or set unexpected error modes.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/flp32-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.uncheckedrangedomainpoleerrors.UncheckedRangeDomainPoleErrors

class UncheckedRangeDomainPoleErrorsQuery extends UncheckedRangeDomainPoleErrorsSharedQuery {
  UncheckedRangeDomainPoleErrorsQuery() {
    this = FloatingTypesPackage::uncheckedRangeDomainPoleErrorsQuery()
  }
}
