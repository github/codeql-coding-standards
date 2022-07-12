/**
 * @id cpp/autosar/useless-assignment
 * @name A0-1-1: Non-volatile variable assigned a value which is never used
 * @description A project shall not contain instances of non-volatile variables being given values
 *              that are not subsequently used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-1
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.CodingStandards
import codingstandards.cpp.deadcode.UselessAssignments
import codingstandards.cpp.exclusions.cpp.RuleMetadata

/* This is a copy of an AUTOSAR rule, which we are using for testing purposes. */
from SsaDefinition ultimateDef, InterestingStackVariable v
where
  not isExcluded(v, DeadCodePackage::uselessAssignmentQuery()) and
  isUselessSsaDefinition(ultimateDef, v)
select ultimateDef, "Definition of $@ is unused.", v, v.getName()
