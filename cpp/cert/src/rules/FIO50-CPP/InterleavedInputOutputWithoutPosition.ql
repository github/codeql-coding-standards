/**
 * @id cpp/cert/interleaved-input-output-without-position
 * @name FIO50-CPP: Do not alternately input and output from a file stream without an intervening positioning call
 * @description Alternating input and output from a file stream without an intervening positioning
 *              call is undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio50-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.iofstreammissingpositioning.IOFstreamMissingPositioning

class InterleavedInputOutputWithoutPositionQuery extends IOFstreamMissingPositioningSharedQuery {
  InterleavedInputOutputWithoutPositionQuery() {
    this = IOPackage::interleavedInputOutputWithoutPositionQuery()
  }
}
