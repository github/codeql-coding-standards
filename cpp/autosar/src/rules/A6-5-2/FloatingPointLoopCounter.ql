/**
 * @id cpp/autosar/floating-point-loop-counter
 * @name A6-5-2: Loop with floating point counter
 * @description A for loop shall contain a single loop-counter which shall not have floating-point
 *              type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a6-5-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Loops

from ForStmt fs, Variable v
where
  not isExcluded(fs, LoopsPackage::floatingPointLoopCounterQuery()) and
  isForLoopWithFloatingPointCounters(fs, v)
select v, "Loop iteration variable " + v.getName() + " has a floating-point type."
