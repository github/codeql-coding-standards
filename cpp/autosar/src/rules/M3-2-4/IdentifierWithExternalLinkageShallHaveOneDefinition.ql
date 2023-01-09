/**
 * @id cpp/autosar/identifier-with-external-linkage-shall-have-one-definition
 * @name M3-2-4: An identifier with external linkage shall have exactly one definition
 * @description An identifier with multiple definitions in different translation units leads to
 *              undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/m3-2-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.identifierwithexternallinkageonedefinitionshared.IdentifierWithExternalLinkageOneDefinitionShared

class IdentifierWithExternalLinkageOneDefinitionQuery extends IdentifierWithExternalLinkageOneDefinitionSharedSharedQuery {
  IdentifierWithExternalLinkageOneDefinitionQuery() {
    this = ScopePackage::identifierWithExternalLinkageShallHaveOneDefinitionQuery()
  }
}
