/**
 * @id cpp/autosar/indexing-not-the-only-form-of-pointer-arithmetic
 * @name M5-0-15: Array indexing shall be the only form of pointer arithmetic
 * @description Array indexing shall be the only form of pointer arithmetic because it less error
 *              prone than pointer manipulation.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/m5-0-15
 *       correctness
 *       external/autosar/strict
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.useonlyarrayindexingforpointerarithmetic.UseOnlyArrayIndexingForPointerArithmetic

class IndexingNotTheOnlyFormOfPointerArithmeticQuery extends UseOnlyArrayIndexingForPointerArithmeticSharedQuery {
  IndexingNotTheOnlyFormOfPointerArithmeticQuery() {
    this = PointersPackage::indexingNotTheOnlyFormOfPointerArithmeticQuery()
  }
}
