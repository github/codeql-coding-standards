/**
 * @id c/cert/use-valid-specifier-flags
 * @name FIO47-C: Use valid specifier flags
 * @description Use valid specifier flags
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio47-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

string getInvalidFlag(string specChar) {
  specChar = ["d", "i", "u"] and result = ["#"]
  or
  specChar = ["o", "x", "X", "e", "E"] and result = ["'"]
  or
  specChar = ["c", "s", "p", "n", "C", "S", "%"] and result = ["'", "#", "0"]
}

from FormatLiteral fl, string specChar, string flags
where
  not isExcluded(fl, IO4Package::useValidSpecifierFlagsQuery()) and
  flags = fl.getFlags(_) and
  specChar = fl.getConversionChar(_) and
  flags.matches("%" + getInvalidFlag(specChar) + "%")
select fl,
  "The conversion specifier '" + specChar + "' is not compatible with flags '" + flags + "'."
