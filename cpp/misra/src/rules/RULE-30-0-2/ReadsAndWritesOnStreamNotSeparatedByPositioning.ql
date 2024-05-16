/**
 * @id cpp/misra/reads-and-writes-on-stream-not-separated-by-positioning
 * @name RULE-30-0-2: Reads and writes on the same file stream shall be separated by a positioning operation
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-30-0-2
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.iofstreammissingpositioning.IOFstreamMissingPositioning

class ReadsAndWritesOnStreamNotSeparatedByPositioningQuery extends IOFstreamMissingPositioningSharedQuery {
  ReadsAndWritesOnStreamNotSeparatedByPositioningQuery() {
    this = ImportMisra23Package::readsAndWritesOnStreamNotSeparatedByPositioningQuery()
  }
}
