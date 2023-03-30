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
import codingstandards.cpp.CharFunctions
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

from UseOfToOrIsChar ctypeCall
where
  not isExcluded(ctypeCall,
    StandardLibraryFunctionTypesPackage::ctypeFunctionArgNotUnsignedCharOrEofQuery()) and
  not exists(Expr ctypeCallArgument | ctypeCallArgument = ctypeCall.getConvertedArgument() |
    /* The argument's value should be in the EOF + `unsigned char` range. */
    -1 <= lowerBound(ctypeCallArgument) and upperBound(ctypeCallArgument) <= 255
  )
select ctypeCall,
  "The <ctype.h> function " + ctypeCall + " accepts an argument " + ctypeCall.getConvertedArgument()
    + " that is not an unsigned char nor an EOF."
