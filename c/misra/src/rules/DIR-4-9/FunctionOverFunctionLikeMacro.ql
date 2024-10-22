/**
 * @id c/misra/function-over-function-like-macro
 * @name DIR-4-9: A function should be used in preference to a function-like macro where they are interchangeable
 * @description Using a function-like macro instead of a function can lead to unexpected program
 *              behaviour.
 * @kind problem
 * @precision medium
 * @problem.severity recommendation
 * @tags external/misra/id/dir-4-9
 *       external/misra/audit
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.functionlikemacrosdefined.FunctionLikeMacrosDefined

class FunctionOverFunctionLikeMacroQuery extends FunctionLikeMacrosDefinedSharedQuery {
  FunctionOverFunctionLikeMacroQuery() {
    this = Preprocessor6Package::functionOverFunctionLikeMacroQuery()
  }
}
