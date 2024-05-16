/**
 * @id cpp/misra/chars-that-should-not-occur-in-header-file-name
 * @name RULE-19-2-3: The ' or " or \ characters and the /* or // character sequences shall not occur in a header file
 * @description The ' or " or \ characters and the /* or // character sequences shall not occur in a
 *              header file name.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-2-3
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.preprocessorincludesforbiddenheadernames.PreprocessorIncludesForbiddenHeaderNames

class CharsThatShouldNotOccurInHeaderFileNameQuery extends PreprocessorIncludesForbiddenHeaderNamesSharedQuery {
  CharsThatShouldNotOccurInHeaderFileNameQuery() {
    this = ImportMisra23Package::charsThatShouldNotOccurInHeaderFileNameQuery()
  }
}
