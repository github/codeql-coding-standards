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

//import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils
class CtypeFunction extends Function {
  CtypeFunction() { this.getADeclaration().getAFile().(HeaderFile).getBaseName() = "ctype.h" }
}

/* TODO Under construction */
from FunctionCall ctypeCall
where
  not isExcluded(ctypeCall,
    StandardLibraryFunctionTypesPackage::ctypeFunctionArgNotUnsignedCharOrEofQuery())
//    and
// not exists(CtypeFunction ctype, Expr ctypeCallArgument |
//   ctype = ctypeCall.getTarget() and
//   ctypeCallArgument = ctypeCall.getAnArgument().getExplicitlyConverted()
// |
//   /* Case 1: The argument's value should be in the `unsigned char` range. */
//   // Use `.getExplicitlyConverted` to consider inline argument casts.
//   -1 <= lowerBound(ctypeCallArgument) and
//   upperBound(ctypeCallArgument) <= 255
//   or
//   /* Case 2: EOF flows to this argument without modifications. */
//   exists(EOFInvocation eof |
//     DataFlow::localFlow(DataFlow::exprNode(eof.getExpr()), DataFlow::exprNode(ctypeCallArgument))
//   )
// )
select ctypeCall.getAnArgument(), lowerBound(ctypeCall.getAnArgument()),
  upperBound(ctypeCall.getAnArgument())
// select ctypeCall,
//   "The <ctype.h> function " + ctypeCall + " accepts an argument " +
//     ctypeCall.getAnArgument().toString() + " that is not an unsigned char nor an EOF."
