/**
 * @id cpp/autosar/unary-operator-overloaded
 * @name M5-3-3: The unary & operator shall not be overloaded
 * @description The unary & operator shall not be overloaded.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-3-3
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Operator o
where
  not isExcluded(o, OperatorsPackage::unaryOperatorOverloadedQuery()) and
  o.hasName("operator&") and
  (
    if o instanceof MemberFunction
    then o.getNumberOfParameters() = 0
    else o.getNumberOfParameters() = 1
  )
select o, "The unary & operator overloaded."
