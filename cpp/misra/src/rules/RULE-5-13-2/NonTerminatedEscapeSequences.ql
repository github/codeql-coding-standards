/**
 * @id cpp/misra/non-terminated-escape-sequences
 * @name RULE-5-13-2: Octal escape sequences, hexadecimal escape sequences, and universal character names shall be
 * @description Octal escape sequences, hexadecimal escape sequences, and universal character names
 *              shall be terminated.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-13-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.nonterminatedescapesequences.NonTerminatedEscapeSequences

class NonTerminatedEscapeSequencesQuery extends NonTerminatedEscapeSequencesSharedQuery {
  NonTerminatedEscapeSequencesQuery() {
    this = ImportMisra23Package::nonTerminatedEscapeSequencesQuery()
  }
}
