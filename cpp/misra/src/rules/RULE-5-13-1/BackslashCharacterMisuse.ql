/**
 * @id cpp/misra/backslash-character-misuse
 * @name RULE-5-13-1: In character literals and non-raw string literals, \ shall only be used to form a defined escape
 * @description In character literals and non-raw string literals, \ shall only be used to form a
 *              defined escape sequence or universal character name.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-13-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.backslashcharactermisuse_shared.BackslashCharacterMisuse_shared

class BackslashCharacterMisuseQuery extends BackslashCharacterMisuse_sharedSharedQuery {
  BackslashCharacterMisuseQuery() {
    this = ImportMisra23Package::backslashCharacterMisuseQuery()
  }
}
