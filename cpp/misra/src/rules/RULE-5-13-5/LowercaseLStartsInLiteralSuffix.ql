/**
 * @id cpp/misra/lowercase-l-starts-in-literal-suffix
 * @name RULE-5-13-5: The lowercase form of L shall not be used as the first character in a literal suffix
 * @description The lowercase form of L shall not be used as the first character in a literal
 *              suffix.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-13-5
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.lowercaselstartsinliteralsuffix_shared.LowercaseLStartsInLiteralSuffix_shared

class LowercaseLStartsInLiteralSuffixQuery extends LowercaseLStartsInLiteralSuffix_sharedSharedQuery
{
  LowercaseLStartsInLiteralSuffixQuery() {
    this = ImportMisra23Package::lowercaseLStartsInLiteralSuffixQuery()
  }
}
