/**
 * @id c/misra/identifier-with-external-linkage-one-definition
 * @name RULE-8-6: An identifier with external linkage shall have exactly one definition
 * @description An identifier with multiple definitions in different translation units leads to
 *              undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-8-6
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.identifierwithexternallinkageonedefinitionshared.IdentifierWithExternalLinkageOneDefinitionShared

class IdentifierWithExternalLinkageShallHaveOneDefinitionQuery extends IdentifierWithExternalLinkageOneDefinitionSharedSharedQuery {
  IdentifierWithExternalLinkageShallHaveOneDefinitionQuery() {
    this = Declarations4Package::identifierWithExternalLinkageOneDefinitionQuery()
  }
}
