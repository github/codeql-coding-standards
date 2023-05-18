/**
 * @id c/misra/identifiers-used-in-preprocessor-expression
 * @name RULE-20-9: All identifiers used in the controlling expression of #if or #elif preprocessing directives shall be
 * @description Using undefined macro identifiers in #if or #elif pre-processor directives, except
 *              as operands to the defined operator, can cause the code to be hard to understand
 *              because the preprocessor will just treat the value as 0 and no warning is given.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-9
 *       correctness
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.undefinedmacroidentifiers.UndefinedMacroIdentifiers

class UndefinedMacroIdentifiersUsedInQuery extends UndefinedMacroIdentifiersSharedQuery {
  UndefinedMacroIdentifiersUsedInQuery() {
    this = Preprocessor1Package::identifiersUsedInPreprocessorExpressionQuery()
  }
}
