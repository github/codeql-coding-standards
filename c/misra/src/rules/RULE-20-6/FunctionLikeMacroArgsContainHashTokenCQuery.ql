/**
 * @id c/misra/function-like-macro-args-contain-hash-token-c-query
 * @name RULE-20-6: Tokens that look like a preprocessing directive shall not occur within a macro argument
 * @description Arguments to a function-like macro shall not contain tokens that look like
 *              pre-processing directives or else behaviour after macro expansion is unpredictable.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-6
 *       readability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.preprocessingdirectivewithinmacroargument.PreprocessingDirectiveWithinMacroArgument

class FunctionLikeMacroArgsContainHashTokenCQueryQuery extends PreprocessingDirectiveWithinMacroArgumentSharedQuery {
  FunctionLikeMacroArgsContainHashTokenCQueryQuery() {
    this = Preprocessor4Package::functionLikeMacroArgsContainHashTokenCQueryQuery()
  }
}
