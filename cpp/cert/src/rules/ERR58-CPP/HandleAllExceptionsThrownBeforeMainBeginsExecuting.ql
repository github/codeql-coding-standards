/**
 * @id cpp/cert/handle-all-exceptions-thrown-before-main-begins-executing
 * @name ERR58-CPP: Handle all exceptions thrown before main() begins executing
 * @description Exceptions thrown before main begins executing cannot be caught.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err58-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.handleallexceptionsduringstartup.HandleAllExceptionsDuringStartup

class HandleAllExceptionsThrownBeforeMainBeginsExcecutingQuery extends HandleAllExceptionsDuringStartupSharedQuery
{
  HandleAllExceptionsThrownBeforeMainBeginsExcecutingQuery() {
    this = Exceptions1Package::handleAllExceptionsThrownBeforeMainBeginsExecutingQuery()
  }
}
