/**
 * @id cpp/autosar/not-equals-in-loop-condition
 * @name M6-5-2: Loop-counter incremented/decremented by more than one shall be an operand to <=, <, >, or >=
 * @description If loop-counter is not modified by -- or ++, then, within condition, the
 *              loop-counter shall only be used as an operand to <=, <, > or >=.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m6-5-2
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Loops

from ForStmt fs, LoopControlVariable v
where
  not isExcluded(fs, LoopsPackage::notEqualsInLoopConditionQuery()) and
  isInvalidForLoopIncrementation(fs, v, _)
select fs,
  "For-loop counter $@ is updated by an increment larger than 1 and tested in the condition using == or !=.",
  v, v.getName()
