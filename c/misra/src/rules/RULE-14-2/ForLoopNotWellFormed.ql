/**
 * @id c/misra/for-loop-not-well-formed
 * @name RULE-14-2: A for loop shall be well-formed
 * @description A well-formed for loop makes code easier to review.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-14-2
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Loops

from ForStmt for
where
  not isExcluded(for, Statements4Package::forLoopNotWellFormedQuery()) and
  isInvalidLoop(for)
select for, "For loop is not well formed."
