/**
 * @id cpp/misra/no-csetjmp-header
 * @name RULE-21-10-2: The standard header file <csetjmp> shall not be used
 * @description Using facilities from the <csetjmp> header causes undefined behavior by bypassing
 *              normal function return mechanisms and may result in non-trivial object destruction
 *              being omitted.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-10-2
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.BannedFunctions
import codingstandards.cpp.types.Uses

class CSetJmpHeader extends Include {
  CSetJmpHeader() { this.getIncludeText().regexpMatch("[<\\\"](csetjmp|setjmp.h)[>\\\"]") }
}

class JmpBufType extends UserType {
  JmpBufType() { this.hasGlobalOrStdName("jmp_buf") }
}

class LongjmpFunction extends Function {
  LongjmpFunction() { this.hasGlobalOrStdName("longjmp") }
}

class SetjmpMacroInvocation extends MacroInvocation {
  SetjmpMacroInvocation() { this.getMacroName() = "setjmp" }
}

from Element element, string message
where
  not isExcluded(element, BannedAPIsPackage::noCsetjmpHeaderQuery()) and
  (
    message = "Use of banned header " + element.(CSetJmpHeader).getIncludeText() + "."
    or
    (
      element = getATypeUse(any(JmpBufType jbt)) and
      if element instanceof Variable
      then
        message =
          "Declaration of variable '" + element.(Variable).getName() +
            "' with banned type 'jmp_buf'."
      else message = "Use of banned type 'jmp_buf'."
    )
    or
    message =
      element.(BannedFunctions<LongjmpFunction>::Use).getAction() + " banned function '" +
        element.(BannedFunctions<LongjmpFunction>::Use).getFunctionName() + "'."
    or
    element instanceof SetjmpMacroInvocation and
    message = "Use of banned macro 'setjmp'."
  )
select element, message
