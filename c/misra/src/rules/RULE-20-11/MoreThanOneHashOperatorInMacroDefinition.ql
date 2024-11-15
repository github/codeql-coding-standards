/**
 * @id c/misra/more-than-one-hash-operator-in-macro-definition
 * @name RULE-20-11: A macro parameter immediately following a # operator shall not immediately be followed by a ##
 * @description The order of evaluation for the '#' and '##' operators may differ between compilers,
 *              which can cause unexpected behaviour if more than one '#' or '##' operator is used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-11
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.macroparameterfollowinghash.MacroParameterFollowingHash

class MoreThanOneHashOperatorInMacroDefinitionQuery extends MacroParameterFollowingHashSharedQuery {
  MoreThanOneHashOperatorInMacroDefinitionQuery() {
    this = Preprocessor2Package::moreThanOneHashOperatorInMacroDefinitionQuery()
  }
}
