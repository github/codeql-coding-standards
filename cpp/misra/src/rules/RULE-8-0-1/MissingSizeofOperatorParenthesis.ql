/**
 * @id cpp/misra/missing-sizeof-operator-parenthesis
 * @name RULE-8-0-1: Parentheses should be used to make the meaning of an expression appropriately explicit
 * @description Usage of parentheses improve program clarity when using the sizeof() operator.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-0-1
 *       scope/single-translation-unit
 *       readability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Locations as Locations

from SizeofExprOperator sizeof
where
  not isExcluded(sizeof, Expressions2Package::missingSizeofOperatorParenthesisQuery()) and
  // Cannot use offset magic in macro expansions.
  not sizeof.isInMacroExpansion() and
  // In `sizeof(x)`, `x` ends before the `sizeof` expr, and in `sizeof x`, `x` and the `sizeof` expr
  // end at the same line & column.
  Locations::shareEnding(sizeof, sizeof.getExprOperand())
select sizeof, "Sizeof operator used without parenthesis."
