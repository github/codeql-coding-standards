/**
 * @id cpp/misra/disallowed-use-of-pragma
 * @name RULE-19-6-1: The #pragma directive and the _Pragma operator should not be used
 * @description Preprocessor pragma directives are implementation-defined, and should not be used to
 *              maintain code portability.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-19-6-1
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from PreprocessorDirective pragma, string kind
where
  not isExcluded(pragma, Preprocessor2Package::disallowedUseOfPragmaQuery()) and
  (
    pragma instanceof PreprocessorPragma and
    kind = "#pragma directive '" + pragma.getHead() + "'"
    or
    exists(string headOrBody, string pragmaOperand |
      headOrBody = [pragma.getHead(), pragma.(Macro).getBody()] and
      pragmaOperand = headOrBody.regexpCapture(".*\\b(_Pragma\\b\\s*\\([^\\)]+\\)).*", 1) and
      kind = "_Pragma operator used: '" + pragmaOperand + "'"
    )
  )
select pragma, "Non-compliant " + kind + "."
