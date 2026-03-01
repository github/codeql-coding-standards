/**
 * @id cpp/misra/invalid-token-in-defined-operator
 * @name RULE-19-1-1: The defined preprocessor operator shall be used appropriately
 * @description Using the defined operator without an immediately following optionally parenthesized
 *              identifier results in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-1-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

string idRegex() { result = "[a-zA-Z_]([a-zA-Z_0-9]*)" }

bindingset[body]
predicate hasInvalidDefinedOperator(string body) {
  body.regexpMatch(".*\\bdefined" +
      // Contains text "defined" at a word break
      // Negative zero width lookahead:
      "(?!(" +
      // (group) optional whitespace followed by a valid identifier
      "(\\s*" + idRegex() + ")" +
      // or
      "|" +
      // (group) optional whitespace followed by parenthesis and valid identifier
      "(\\s*\\(\\s*" + idRegex() + "\\s*\\))" +
      // End negative zero width lookahead, match remaining text
      ")).*")
}

from PreprocessorIf ifDirective
where
  not isExcluded(ifDirective, PreprocessorPackage::invalidTokenInDefinedOperatorQuery()) and
  hasInvalidDefinedOperator(ifDirective.getHead())
select ifDirective, "Invalid use of defined operator in if directive."
