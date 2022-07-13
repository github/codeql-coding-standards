/**
 * @id cpp/autosar/multiple-loop-counters
 * @name A6-5-2: Loop with multiple loop counters
 * @description A for loop shall contain a single loop-counter.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a6-5-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Loops

from ForStmt fs
where
  not isExcluded(fs, LoopsPackage::multipleLoopCountersQuery()) and
  isForLoopWithMulipleCounters(fs)
select fs, "For loop has multiple loop counters."
