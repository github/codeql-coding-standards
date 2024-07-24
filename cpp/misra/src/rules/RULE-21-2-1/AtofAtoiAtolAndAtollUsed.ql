/**
 * @id cpp/misra/atof-atoi-atol-and-atoll-used
 * @name RULE-21-2-1: The library functions atof, atoi, atol and atoll from <cstdlib> shall not be used
 * @description The library functions atof, atoi, atol and atoll from <cstdlib> shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-2-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.atofatoiatolandatollused.AtofAtoiAtolAndAtollUsed

class AtofAtoiAtolAndAtollUsedQuery extends AtofAtoiAtolAndAtollUsedSharedQuery {
  AtofAtoiAtolAndAtollUsedQuery() { this = ImportMisra23Package::atofAtoiAtolAndAtollUsedQuery() }
}
