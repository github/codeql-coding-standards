/**
 * @id c/cert/to-character-handling-functions-representable-as-u-char
 * @name STR37-C: Arguments to character-handling functions must be representable as an unsigned char
 * @description Arguments that are not representable as an unsigned char may produce unpredictable
 *              program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/str37-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.CharFunctions

from FunctionCall fc, Expr arg
where
  not isExcluded(fc, Strings2Package::toCharacterHandlingFunctionsRepresentableAsUCharQuery()) and
  // examine all impacted functions
  fc.getTarget() instanceof CToOrIsCharFunction and
  arg = fc.getArgument(0).getFullyConverted() and
  // report on cases where either the explicit or implicit cast
  // on the parameter type is not unsigned
  not arg.(CStyleCast).getExpr().getType() instanceof UnsignedCharType
select fc, "$@ to character-handling function may not be representable as an unsigned char.", arg,
  "Argument"
