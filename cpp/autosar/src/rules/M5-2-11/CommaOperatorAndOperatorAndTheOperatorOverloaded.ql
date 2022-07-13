/**
 * @id cpp/autosar/comma-operator-and-operator-and-the-operator-overloaded
 * @name M5-2-11: The comma operator, && operator and the || operator shall not be overloaded
 * @description The comma operator, && operator and the || operator shall not be overloaded.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-2-11
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Operator o
where
  not isExcluded(o, OperatorsPackage::commaOperatorAndOperatorAndTheOperatorOverloadedQuery()) and
  exists(string name | name = o.getName() |
    name = "operator," or
    name = "operator&&" or
    name = "operator||"
  )
select o, "The " + o.getName().suffix("operator".length()) + " operator should not be overloaded ."
