/**
 * @id c/misra/ctype-function-arg-not-unsigned-char-or-eof
 * @name RULE-21-13: <ctype.h> function arguments shall be represented as unsigned char
 * @description Passing arguments to <ctype.h> functions outside the range of unsigned char or EOF
 *              causes undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-13
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.ReadErrorsAndEOF
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

class CtypeFunction extends Function {
  CtypeFunction() { this.getADeclaration().getAFile().(HeaderFile).getBaseName() = "ctype.h" }
}

from FunctionCall ctypeCall
where
  not isExcluded(ctypeCall,
    StandardLibraryFunctionTypesPackage::ctypeFunctionArgNotUnsignedCharOrEofQuery()) and
  not exists(CtypeFunction ctype, Expr ctypeCallArgument |
    ctype = ctypeCall.getTarget() and
    ctypeCallArgument = ctypeCall.getAnArgument().getExplicitlyConverted()
  |
    /* The argument's value should be in the EOF + `unsigned char` range. */
    -1 <= lowerBound(ctypeCallArgument) and upperBound(ctypeCallArgument) <= 255
  ) and
  /* Only report control flow that is feasible (to avoid <ctype.h> functions implemented as macro). */
  ctypeCall.getBasicBlock().isReachable()
select ctypeCall,
  "The <ctype.h> function " + ctypeCall + " accepts an argument " +
    ctypeCall.getAnArgument().toString() + " that is not an unsigned char nor an EOF."
