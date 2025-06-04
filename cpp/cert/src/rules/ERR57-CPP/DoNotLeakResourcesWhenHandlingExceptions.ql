/**
 * @id cpp/cert/do-not-leak-resources-when-handling-exceptions
 * @name ERR57-CPP: Do not leak resources when handling exceptions
 * @description Do not leak resources when handling exceptions.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err57-cpp
 *       correctness
 *       security
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.exceptionsafetyvalidstate.ExceptionSafetyValidState

class DoNotLeakResourcesWhenHandlingExceptionsQuery extends ExceptionSafetyValidStateSharedQuery {
  DoNotLeakResourcesWhenHandlingExceptionsQuery() {
    this = ExceptionSafetyPackage::doNotLeakResourcesWhenHandlingExceptionsQuery()
  }
}
