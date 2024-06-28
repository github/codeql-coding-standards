/**
 * @id cpp/misra/octal-constants-used
 * @name RULE-5-13-3: Octal constants shall not be used
 * @description Octal constants shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-13-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.useofnonzerooctalliteral_shared.UseOfNonZeroOctalLiteral_shared

class OctalConstantsUsedQuery extends UseOfNonZeroOctalLiteral_sharedSharedQuery {
  OctalConstantsUsedQuery() { this = ImportMisra23Package::octalConstantsUsedQuery() }
}
