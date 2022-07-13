/**
 * @id cpp/autosar/user-defined-conversion-operators-should-not-be-used
 * @name A13-5-3: User-defined conversion operators should not be used
 * @description User-defined conversion operators should not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a13-5-3
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from FunctionCall fc
where
  not isExcluded(fc, OperatorsPackage::userDefinedConversionOperatorsShouldNotBeUsedQuery()) and
  fc.getTarget() instanceof ConversionOperator
select fc, "User-defined conversion operators should not be used."
