/**
 * @id cpp/autosar/floats-tested-for-equality
 * @name M6-2-2: Floating-point expressions shall not be directly or indirectly tested for equality or inequality
 * @description The inherent nature of floating-point types is such that comparisons of equality
 *              will often not evaluate to true, even when they are expected to. Also, the behaviour
 *              of such a comparison cannot be predicted before execution, and may well vary from
 *              one implementation to another.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m6-2-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from ComparisonOperation co
where
  not isExcluded(co, ExpressionsPackage::floatsTestedForEqualityQuery()) and
  co.getAnOperand().getType() instanceof FloatingPointType
select co, "Use of floating-point value in comparison operation."
