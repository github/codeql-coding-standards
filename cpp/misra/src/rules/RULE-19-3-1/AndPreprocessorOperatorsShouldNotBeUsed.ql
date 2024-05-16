/**
 * @id cpp/misra/and-preprocessor-operators-should-not-be-used
 * @name RULE-19-3-1: The # and ## preprocessor operators should not be used
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-3-1
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.hashoperatorsused.HashOperatorsUsed

class AndPreprocessorOperatorsShouldNotBeUsedQuery extends HashOperatorsUsedSharedQuery {
  AndPreprocessorOperatorsShouldNotBeUsedQuery() {
    this = ImportMisra23Package::andPreprocessorOperatorsShouldNotBeUsedQuery()
  }
}
