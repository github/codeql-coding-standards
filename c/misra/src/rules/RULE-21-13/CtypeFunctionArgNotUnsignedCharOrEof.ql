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
import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils

class CtypeFunction extends Function {
  CtypeFunction() { this.getADeclaration().getAFile().(HeaderFile).getShortName() = "_ctype" }
}

from FunctionCall ctypeCall
where
  not isExcluded(ctypeCall,
    StandardLibraryFunctionTypesPackage::ctypeFunctionArgNotUnsignedCharOrEofQuery()) and
  not exists(CtypeFunction ctype, UnsignedCharType unsignedChar |
    ctypeCall = ctype.getACallToThisFunction()
  |
    /* The argument's value should be in the `unsigned char` range. */
    typeLowerBound(unsignedChar) <= lowerBound(ctypeCall.getAnArgument().getExplicitlyConverted()) and // consider casts
    upperBound(ctypeCall.getAnArgument().getExplicitlyConverted()) <= typeUpperBound(unsignedChar)
    or
    /* The argument's value is reachable from EOF. */
    exists(EOFInvocation eof |
      DataFlow::localFlow(DataFlow::exprNode(eof.getExpr()),
        DataFlow::exprNode(ctypeCall.getAnArgument()))
    )
  )
select ctypeCall,
  "The <ctype.h> function $@ accepts an argument $@ that is not unsigned char nor an EOF.",
  ctypeCall, ctypeCall.getTarget(), ctypeCall.getAnArgument(), ctypeCall.getAnArgument().toString()
