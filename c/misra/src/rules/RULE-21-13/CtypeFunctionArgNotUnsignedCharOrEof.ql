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
import semmle.code.cpp.dataflow.DataFlow // TODO use this...

query predicate isCtypeFunction(Function function) {
  function.getADeclaration().getAFile().(HeaderFile).getShortName() = "_ctype" // TODO: change it back to `ctype`
}

query predicate isInUnsignedCharRange(Expr var) {
  // TODO: shouldn't be an Expr, instead get it as an argument from a FunctionCall that isCtypeFunction
  exists(UnsignedCharType unsignedChar |
    // Consider cases where the argument's value is cast to some smaller type, clipping the range.
    typeLowerBound(unsignedChar) <= lowerBound(var.getFullyConverted()) and
    upperBound(var.getFullyConverted()) <= typeUpperBound(unsignedChar)
  )
}

// Uh oh, this is empty
query predicate isEOFInvocation(EOFInvocation eof) {
  any()
}

/* very early draft */
query predicate equivToEOF(FunctionCall fc, EOFInvocation eof) {
  // var is a param of ctypefunctioncall
  isCtypeFunction(fc.getTarget()) and
  DataFlow::localFlow(DataFlow::exprNode(eof.getExpr()), DataFlow::exprNode(fc.getArgument(0)))
}
from Element x
where
  not isExcluded(x, StandardLibraryFunctionTypesPackage::ctypeFunctionArgNotUnsignedCharOrEofQuery()) and
  any()
select 1
