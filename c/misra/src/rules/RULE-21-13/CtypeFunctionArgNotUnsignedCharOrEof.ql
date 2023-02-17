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

from
where
  not isExcluded(x, StandardLibraryFunctionTypesPackage::ctypeFunctionArgNotUnsignedCharOrEofQuery()) and
select
