/**
 * @id cpp/autosar/user-defined-conversion-operators-not-defined-explicit
 * @name A13-5-2: All user-defined conversion operators shall be defined explicit
 * @description All user-defined conversion operators shall be defined explicit.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a13-5-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class ExplicitConversionOperator extends ConversionOperator {
  ExplicitConversionOperator() {
    exists(Specifier spec |
      spec = this.getASpecifier() and
      spec.hasName("explicit")
    )
  }
}

from ConversionOperator op
where
  not isExcluded(op, OperatorsPackage::userDefinedConversionOperatorsNotDefinedExplicitQuery()) and
  not op instanceof ExplicitConversionOperator and
  not op.isCompilerGenerated()
select op, "User-defined conversion operator is not explicit."
