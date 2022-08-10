/**
 * @id c/cert/use-valid-specifier-length
 * @name FIO47-C: Use valid specifier length
 * @description Use valid specifier length
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

string getInvalidLength(string specChar) {
  specChar = ["d", "i", "o", "u", "n"] and result = ["L"]
  or
  specChar = ["f", "F", "e", "E", "g", "G", "a", "A"] and result = ["h", "hh", "j", "z", "t"]
  or
  specChar = ["c", "s"] and result = ["h", "hh", "ll", "j", "z", "t", "L"]
  or
  specChar = ["p", "C", "S", "%"] and result = ["h", "hh", "l", "ll", "j", "z", "t", "L"]
}

from FormatLiteral fl, string specChar, string length
where
  not isExcluded(fl, IO4Package::useValidSpecifierLengthQuery()) and
  length = fl.getLength(_) and
  specChar = fl.getConversionChar(_) and
  length.matches("%" + getInvalidLength(specChar) + "%")
select fl,
  "The conversion specifier '" + specChar + "' is not compatible with length '" + length + "'."
