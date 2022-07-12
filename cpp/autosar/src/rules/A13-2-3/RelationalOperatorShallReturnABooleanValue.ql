/**
 * @id cpp/autosar/relational-operator-shall-return-a-boolean-value
 * @name A13-2-3: A relational operator shall return a boolean value
 * @description A relational operator shall return a boolean value to be consistent with the C++
 *              Standard Library.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a13-2-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

from UserComparisonOperator op
where
  not isExcluded(op, OperatorsPackage::relationalOperatorShallReturnABooleanValueQuery()) and
  not op.getType() instanceof BoolType
select op, "User defined comparison operator does not have a boolean return type."
