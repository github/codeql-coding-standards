/**
 * @id cpp/autosar/divisor-equal-to-zero
 * @name A5-6-1: The right operand of the integer division or remainder operators shall not be equal to zero
 * @description The result is undefined if the right hand operand of the integer division or the
 *              remainder operator is zero.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a5-6-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.divisorequaltozeroshared.DivisorEqualToZeroShared

module DivisorEqualToZeroConfig implements DivisorEqualToZeroSharedConfigSig {
  Query getQuery() { result = ExpressionsPackage::divisorEqualToZeroQuery() }
}

import DivisorEqualToZeroShared<DivisorEqualToZeroConfig>
