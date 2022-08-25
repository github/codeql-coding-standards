/**
 * @id c/cert/use-valid-specifiers
 * @name FIO47-C: Use valid format strings
 * @description Invalid conversion specifiers leads to undefined behavior.
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
  specChar = ["c", "s", "p", "C", "S", "%"] and result = ["'", "#", "0"]
  or
  specChar = ["n"] and result = ["'", "-", "+", " ", "#", "0"]
}

string getInvalidLength(string specChar) {
  specChar = ["d", "i", "o", "u", "x", "X", "n"] and result = ["L"]
  or
  specChar = ["f", "F", "e", "E", "g", "G", "a", "A"] and result = ["h", "hh", "j", "z", "t"]
  or
  specChar = ["c", "s"] and result = ["h", "hh", "ll", "j", "z", "t", "L"]
  or
  specChar = ["p", "C", "S", "%"] and result = ["h", "hh", "l", "ll", "j", "z", "t", "L"]
}

from FormatLiteral x, string message
where
  not isExcluded(x, IO4Package::useValidSpecifiersQuery()) and
  message = "The conversion specifier '" + x + "' is not valid." and
  not x.specsAreKnown()
  or
  exists(string compatible, string specChar, int n |
    message =
      "The conversion specifier '" + specChar + "' is not compatible with flags '" + compatible +
        "'" and
    compatible = x.getFlags(n) and
    specChar = x.getConversionChar(n) and
    compatible.matches("%" + getInvalidFlag(specChar) + "%")
    or
    message =
      "The conversion specifier '" + specChar + "' is not compatible with length '" + compatible +
        "'" and
    compatible = x.getLength(n) and
    specChar = x.getConversionChar(n) and
    compatible.matches("%" + getInvalidLength(specChar) + "%")
  )
select x, message
