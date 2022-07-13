/**
 * @id cpp/autosar/operators-should-be-declared-with-the-ref-qualifier
 * @name A12-8-7: Assignment operators should be declared with the ref-qualifier &
 * @description Assignment operators should be declared with the ref-qualifier &.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a12-8-7
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

from UserAssignmentOperator uso
where
  not isExcluded(uso, OperatorsPackage::operatorsShouldBeDeclaredWithTheRefQualifierQuery()) and
  not uso.isLValueRefQualified()
select uso, "Assign operators declared without the ref-qualifier &"
