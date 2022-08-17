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

predicate isLongJumpCall(FunctionCall fc) { fc.getTarget().hasGlobalOrStdName("longjmp") }

predicate isSetJumpCall(MacroInvocation mi) { mi.getMacroName() = "setjmp" }

from Element jmp, string callType
where
  not isExcluded(jmp, BannedFunctionsPackage::setjmpMacroAndTheLongjmpFunctionUsedQuery()) and
  (
    isLongJumpCall(jmp) and callType = "longjmp function"
    or
    isSetJumpCall(jmp) and callType = "setjmp macro"
  )
select jmp, "Use of banned " + callType + "."
