/**
 * @id cpp/autosar/catch-all-handler-last
 * @name M15-3-7: Where multiple handlers are provided in a single try-catch statement or function-try-block, any ellipsis (catch-all) handler shall occur last
 * @description A catch-all handler will shadow catch handlers defined later in the try-catch.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m15-3-7
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from CatchAnyBlock catchAnyBlock, TryStmt tryStmt, int catchAnyIndex
where
  not isExcluded(catchAnyBlock, Exceptions1Package::catchAllHandlerLastQuery()) and
  catchAnyBlock = tryStmt.getCatchClause(catchAnyIndex) and
  not catchAnyIndex = tryStmt.getNumberOfCatchClauses() - 1
select catchAnyBlock, "Catch-all handler is not final catch statement."
