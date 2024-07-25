/**
 * @id cpp/autosar/identifier-main-used-for-a-function-other-than-the-global-function-main
 * @name M7-3-2: The identifier main shall not be used for a function other than the global function main
 * @description Reusing the name main in non-main contexts can lead to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m7-3-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.nonglobalfunctionmain.NonGlobalFunctionMain

class IdentifierMainUsedForAFunctionOtherThanTheGlobalFunctionMainQuery extends NonGlobalFunctionMainSharedQuery {
  IdentifierMainUsedForAFunctionOtherThanTheGlobalFunctionMainQuery() {
    this = NamingPackage::identifierMainUsedForAFunctionOtherThanTheGlobalFunctionMainQuery()
  }
}
