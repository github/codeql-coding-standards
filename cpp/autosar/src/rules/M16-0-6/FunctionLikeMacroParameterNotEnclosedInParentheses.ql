/**
 * @id cpp/autosar/function-like-macro-parameter-not-enclosed-in-parentheses
 * @name M16-0-6: In the definition of a function-like macro, each instance of a parameter shall be enclosed in parentheses
 * @description In the definition of a function-like macro, each instance of a parameter shall be
 *              enclosed in parentheses, otherwise the result of preprocessor macro substitition may
 *              not be as expected.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-6
 *       correctness
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.macroparameternotenclosedinparentheses.MacroParameterNotEnclosedInParentheses

class MacroParameterNotEnclosedInParenthesesCQueryQuery extends MacroParameterNotEnclosedInParenthesesSharedQuery {
  MacroParameterNotEnclosedInParenthesesCQueryQuery() {
    this = MacrosPackage::functionLikeMacroParameterNotEnclosedInParenthesesQuery()
  }
}
