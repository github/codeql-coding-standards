/**
 * @id cpp/autosar/if-compound-condition
 * @name M6-4-1: An if ( condition ) construct shall be followed by a compound statement
 * @description If the body of an if statement is not enclosed within brackets then this can lead to
 *              incorrect execution and is hard for developers to maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-1
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from IfStmt ifStmt
where
  not isExcluded(ifStmt, ConditionalsPackage::ifCompoundConditionQuery()) and
  not ifStmt.getThen() instanceof BlockStmt
select ifStmt, "if statement not enclosed within braces."
