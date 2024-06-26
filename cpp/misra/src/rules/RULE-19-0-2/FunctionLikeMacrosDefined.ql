/**
 * @id cpp/misra/function-like-macros-defined
 * @name RULE-19-0-2: Function-like macros shall not be defined
 * @description Function-like macros shall not be defined.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-0-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.functionlikemacrosdefined_shared.FunctionLikeMacrosDefined_shared

class FunctionLikeMacrosDefinedQuery extends FunctionLikeMacrosDefined_sharedSharedQuery {
  FunctionLikeMacrosDefinedQuery() { this = ImportMisra23Package::functionLikeMacrosDefinedQuery() }
}
