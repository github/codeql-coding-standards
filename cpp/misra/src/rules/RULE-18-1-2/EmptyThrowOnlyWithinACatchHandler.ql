/**
 * @id cpp/misra/empty-throw-only-within-a-catch-handler
 * @name RULE-18-1-2: An empty throw shall only occur within the compound-statement of a catch handler
 * @description An empty throw shall only occur within the compound-statement of a catch handler.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-1-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.emptythrowonlywithinacatchhandler.EmptyThrowOnlyWithinACatchHandler

class EmptyThrowOnlyWithinACatchHandlerQuery extends EmptyThrowOnlyWithinACatchHandlerSharedQuery
{
  EmptyThrowOnlyWithinACatchHandlerQuery() {
    this = ImportMisra23Package::emptyThrowOnlyWithinACatchHandlerQuery()
  }
}
