/**
 * @id c/cert/do-not-compare-padding-data
 * @name EXP42-C: Do not compare padding data
 * @description Padding data values are unspecified and should not be included in comparisons.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp42-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.memcmpusedtocomparepaddingdata.MemcmpUsedToComparePaddingData

class DoNotComparePaddingDataQuery extends MemcmpUsedToComparePaddingDataSharedQuery {
  DoNotComparePaddingDataQuery() {
    this = Memory2Package::doNotComparePaddingDataQuery()
  }
}
