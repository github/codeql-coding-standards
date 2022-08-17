/**
 * @id c/cert/do-not-alternately-io-from-a-stream-without-positioning
 * @name FIO39-C: Do not alternately input and output from a stream without an intervening flush or positioning call
 * @description Do not alternately input and output from a stream without an intervening flush or
 *              positioning call. This may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/fio39-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.iofstreammissingpositioning.IOFstreamMissingPositioning

class DoNotAlternatelyIOFromAStreamWithoutPositioningQuery extends IOFstreamMissingPositioningSharedQuery {
  DoNotAlternatelyIOFromAStreamWithoutPositioningQuery() {
    this = IO1Package::doNotAlternatelyIOFromAStreamWithoutPositioningQuery()
  }
}
