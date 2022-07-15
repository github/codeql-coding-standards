/**
 * @id cpp/autosar/function-like-macro-args-contain-hash-token
 * @name M16-0-5: Arguments to a function-like macro shall not contain tokens that look like pre-processing directives
 * @description Arguments to a function-like macro shall not contain tokens that look like
 *              pre-processing directives or else behaviour after macro expansion is unpredictable.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-5
 *       readability
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.preprocessingdirectivewithinmacroargument.PreprocessingDirectiveWithinMacroArgument

class FunctionLikeMacroArgsContainHashTokenCQueryQuery extends PreprocessingDirectiveWithinMacroArgumentSharedQuery {
  FunctionLikeMacroArgsContainHashTokenCQueryQuery() {
    this = MacrosPackage::functionLikeMacroArgsContainHashTokenQuery()
  }
}
