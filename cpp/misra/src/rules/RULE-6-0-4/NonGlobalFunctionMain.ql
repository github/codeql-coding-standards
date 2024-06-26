/**
 * @id cpp/misra/non-global-function-main
 * @name RULE-6-0-4: The identifier main shall not be used for a function other than the global function main
 * @description The identifier main shall not be used for a function other than the global function
 *              main.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-0-4
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.nonglobalfunctionmain_shared.NonGlobalFunctionMain_shared

class NonGlobalFunctionMainQuery extends NonGlobalFunctionMain_sharedSharedQuery {
  NonGlobalFunctionMainQuery() {
    this = ImportMisra23Package::nonGlobalFunctionMainQuery()
  }
}
