/**
 * @id cpp/cert/do-not-use-setjmp-or-longjmp
 * @name ERR52-CPP: Do not use setjmp() or longjmp()
 * @description Do not use setjmp() or longjmp().
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/err52-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

predicate isLongJumpCall(FunctionCall fc) { fc.getTarget().hasGlobalOrStdName("longjmp") }

predicate isSetJumpCall(MacroInvocation mi) { mi.getMacroName() = "setjmp" }

from Element jmp, string callType
where
  not isExcluded(jmp, BannedFunctionsPackage::doNotUseSetjmpOrLongjmpQuery()) and
  (
    isLongJumpCall(jmp) and callType = "longjmp function"
    or
    isSetJumpCall(jmp) and callType = "setjmp macro"
  )
select jmp, "Use of banned " + callType + "."
