/**
 * @id c/cert/excess-length-names-identifiers-not-distinct
 * @name DCL40-C: External identifiers shall be distinct
 * @description Using nondistinct external identifiers results in undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/dcl40-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.notdistinctidentifier.NotDistinctIdentifier

class ExcessLengthNamesIdentifiersNotDistinctQuery extends NotDistinctIdentifierSharedQuery {
  ExcessLengthNamesIdentifiersNotDistinctQuery() {
    this = Declarations2Package::excessLengthNamesIdentifiersNotDistinctQuery()
  }
}
