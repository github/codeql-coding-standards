/**
 * @id c/misra/macro-identifier-not-distinct-from-parameter
 * @name RULE-5-4: Macro identifiers shall be distinct from paramters
 * @description Macros with the same name as their parameters are less readable.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-4
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.FunctionLikeMacro

from FunctionLikeMacro m
where
  not isExcluded(m, Declarations1Package::macroIdentifierNotDistinctFromParameterQuery()) and
  exists(string p | p = m.(FunctionLikeMacro).getAParameter() and p = m.getName())
select m, "Macro name matches parameter " + m.getName() + " ."
