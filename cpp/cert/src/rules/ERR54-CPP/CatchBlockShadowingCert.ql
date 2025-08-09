/**
 * @id cpp/cert/catch-block-shadowing-cert
 * @name ERR54-CPP: Catch handlers should order their parameter types from most derived to least derived
 * @description Catch blocks with less derived types ordered ahead of more derived types can lead to
 *              unreachable catch blocks.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/err54-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.catchblockshadowing.CatchBlockShadowing

class CatchBlockShadowingCertQuery extends CatchBlockShadowingSharedQuery {
  CatchBlockShadowingCertQuery() { this = Exceptions2Package::catchBlockShadowingCertQuery() }
}
