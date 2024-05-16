/**
 * @id cpp/misra/tokens-that-look-like-directives-in-a-macro-argument
 * @name RULE-19-3-5: Tokens that look like a preprocessing directive shall not occur within a macro argument
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-3-5
 *       readability
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.preprocessingdirectivewithinmacroargument.PreprocessingDirectiveWithinMacroArgument

class TokensThatLookLikeDirectivesInAMacroArgumentQuery extends PreprocessingDirectiveWithinMacroArgumentSharedQuery {
  TokensThatLookLikeDirectivesInAMacroArgumentQuery() {
    this = ImportMisra23Package::tokensThatLookLikeDirectivesInAMacroArgumentQuery()
  }
}
