/**
 * @id cpp/autosar/rethrow-nested-without-capture-autosar
 * @name A15-5-3: Calling std::throw_with_nested with no current exception can lead to abrupt termination
 * @description Throwing a nested exception when no exception is currently being handled will cause
 *              the program to terminate if the nested exception is later requested.
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
import codingstandards.cpp.rules.rethrownestedwithoutcapture.RethrowNestedWithoutCapture

class RethrowNestedWithoutCaptureAutosarQuery extends RethrowNestedWithoutCaptureSharedQuery {
  RethrowNestedWithoutCaptureAutosarQuery() {
    this = Exceptions1Package::rethrowNestedWithoutCaptureAutosarQuery()
  }
}
