/**
 * @id cpp/cert/rethrow-nested-without-capture-cert
 * @name ERR50-CPP: Calling std::throw_with_nested with no current exception can lead to abrupt termination
 * @description Throwing a nested exception when no exception is currently being handled will cause
 *              the program to terminate if the nested exception is later requested.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err50-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.rethrownestedwithoutcapture.RethrowNestedWithoutCapture

class RethrowNestedWithoutCaptureCertQuery extends RethrowNestedWithoutCaptureSharedQuery {
  RethrowNestedWithoutCaptureCertQuery() {
    this = Exceptions1Package::rethrowNestedWithoutCaptureCertQuery()
  }
}
