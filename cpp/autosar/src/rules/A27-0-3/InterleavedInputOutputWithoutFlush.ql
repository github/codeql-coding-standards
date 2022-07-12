/**
 * @id cpp/autosar/interleaved-input-output-without-flush
 * @name A27-0-3: Alternate input and output on a file stream shall not be used without intervening positioning calls
 * @description Alternate input and output operations on a file stream shall not be used without an
 *              intervening flush or positioning call.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a27-0-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.iofstreammissingpositioning.IOFstreamMissingPositioning

class InterleavedInputOutputWithoutFlushQuery extends IOFstreamMissingPositioningSharedQuery {
  InterleavedInputOutputWithoutFlushQuery() {
    this = IOPackage::interleavedInputOutputWithoutFlushQuery()
  }
}
