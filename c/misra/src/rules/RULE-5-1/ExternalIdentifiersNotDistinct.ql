/**
 * @id c/misra/external-identifiers-not-distinct
 * @name RULE-5-1: External identifiers shall be distinct
 * @description Using nondistinct external identifiers results in undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-1
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.notdistinctidentifier.NotDistinctIdentifier

class ExternalIdentifiersNotDistinct extends NotDistinctIdentifierSharedQuery {
    ExternalIdentifiersNotDistinct() {
    this = Declarations1Package::externalIdentifiersNotDistinctQuery()
  }
}