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

from UseOfToOrIsChar useOfCharAPI, Expr arg
where
  not isExcluded(useOfCharAPI,
    Strings2Package::toCharacterHandlingFunctionsRepresentableAsUCharQuery()) and
  arg = useOfCharAPI.getConvertedArgument() and
  not arg.getType() instanceof UnsignedCharType
select useOfCharAPI,
  "$@ to character-handling function may not be representable as an unsigned char.", arg, "Argument"
