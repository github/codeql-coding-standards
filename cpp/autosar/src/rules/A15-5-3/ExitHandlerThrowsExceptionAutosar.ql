/**
 * @id cpp/autosar/exit-handler-throws-exception-autosar
 * @name A15-5-3: Registered exit handler throws an exception
 * @description An exit handler which throws an exception causes abrupt termination of the program,
 *              and can leave resources such as streams and temporary files in an unclosed state.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a15-5-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.exithandlerthrowsexception.ExitHandlerThrowsException

class ExitHandlerThrowsExceptionAutosarQuery extends ExitHandlerThrowsExceptionSharedQuery {
  ExitHandlerThrowsExceptionAutosarQuery() {
    this = Exceptions1Package::exitHandlerThrowsExceptionAutosarQuery()
  }
}
