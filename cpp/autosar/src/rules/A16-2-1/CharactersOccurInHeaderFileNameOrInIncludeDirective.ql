/**
 * @id cpp/autosar/characters-occur-in-header-file-name-or-in-include-directive
 * @name A16-2-1: The ', ", /*, //, \ characters shall not occur in a header file name or in #include directive
 * @description Using any of the following characters in an '#include' directive as a part of the
 *              header file name is undefined behaviour: ', ", /*, //, \.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a16-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.preprocessorincludesforbiddenheadernames.PreprocessorIncludesForbiddenHeaderNames

class CharactersOccurInHeaderFileNameOrInIncludeDirectiveQuery extends PreprocessorIncludesForbiddenHeaderNamesSharedQuery {
  CharactersOccurInHeaderFileNameOrInIncludeDirectiveQuery() {
    this = MacrosPackage::charactersOccurInHeaderFileNameOrInIncludeDirectiveQuery()
  }
}
