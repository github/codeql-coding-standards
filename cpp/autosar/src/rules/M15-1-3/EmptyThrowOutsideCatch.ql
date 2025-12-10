/**
 * @id cpp/autosar/empty-throw-outside-catch
 * @name M15-1-3: An empty throw (throw;) shall only be used in the compound statement of a catch handler
 * @description Empty throws with no currently handled exception can cause abrupt program
 *              termination.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m15-1-3
 *       correctness
 *       coding-standards/baseline/safety
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.emptythrowonlywithinacatchhandler.EmptyThrowOnlyWithinACatchHandler

class EmptyThrowOutsideCatchQuery extends EmptyThrowOnlyWithinACatchHandlerSharedQuery {
  EmptyThrowOutsideCatchQuery() { this = Exceptions1Package::emptyThrowOutsideCatchQuery() }
}
