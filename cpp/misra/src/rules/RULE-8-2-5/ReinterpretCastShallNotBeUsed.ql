/**
 * @id cpp/misra/reinterpret-cast-shall-not-be-used
 * @name RULE-8-2-5: reinterpret_cast shall not be used
 * @description reinterpret_cast shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-5
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.reinterpretcastused.ReinterpretCastUsed

class ReinterpretCastShallNotBeUsedQuery extends ReinterpretCastUsedSharedQuery {
  ReinterpretCastShallNotBeUsedQuery() {
    this = ImportMisra23Package::reinterpretCastShallNotBeUsedQuery()
  }
}
