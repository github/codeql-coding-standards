/**
 * @id cpp/autosar/exception-raised-during-startup
 * @name M15-3-1: Exceptions shall be raised only before termination
 * @description Exceptions raised before start-up or during termination can lead to the program
 *              being terminated in an implementation defined manner.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m15-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.handleallexceptionsduringstartup.HandleAllExceptionsDuringStartup

class ExceptionsRaisedDuringStartupQuery extends HandleAllExceptionsDuringStartupSharedQuery {
  ExceptionsRaisedDuringStartupQuery() {
    this = Exceptions2Package::exceptionRaisedDuringStartupQuery()
  }
}
