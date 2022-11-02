/**
 * @id c/misra/macro-parameter-not-enclosed-in-parentheses-c-query
 * @name RULE-20-7: Expressions resulting from the expansion of macro parameters shall be enclosed in parentheses
 * @description In the definition of a function-like macro, each instance of a parameter shall be
 *              enclosed in parentheses, otherwise the result of preprocessor macro substitition may
 *              not be as expected.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-7
 *       correctness
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.macroparameternotenclosedinparentheses.MacroParameterNotEnclosedInParentheses

class MacroParameterNotEnclosedInParenthesesCQueryQuery extends MacroParameterNotEnclosedInParenthesesSharedQuery {
  MacroParameterNotEnclosedInParenthesesCQueryQuery() {
    this = Preprocessor5Package::macroParameterNotEnclosedInParenthesesCQueryQuery()
  }
}
