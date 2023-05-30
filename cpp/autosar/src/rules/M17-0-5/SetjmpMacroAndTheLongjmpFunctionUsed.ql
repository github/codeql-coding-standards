/**
 * @id cpp/autosar/setjmp-macro-and-the-longjmp-function-used
 * @name M17-0-5: The setjmp macro and the longjmp function shall not be used
 * @description The macro setjmp and function longjmp shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m17-0-5
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.donotusesetjmporlongjmpshared.DoNotUseSetjmpOrLongjmpShared

class SetjmpMacroAndTheLongjmpFunctionUsedQuery extends DoNotUseSetjmpOrLongjmpSharedSharedQuery {
  SetjmpMacroAndTheLongjmpFunctionUsedQuery() {
    this = BannedFunctionsPackage::setjmpMacroAndTheLongjmpFunctionUsedQuery()
  }
}
