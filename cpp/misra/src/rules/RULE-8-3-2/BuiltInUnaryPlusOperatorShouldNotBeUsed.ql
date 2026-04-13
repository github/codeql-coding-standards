/**
 * @id cpp/misra/built-in-unary-plus-operator-should-not-be-used
 * @name RULE-8-3-2: The built-in unary + operator should not be used
 * @description Using the built-in unary '+' operator may trigger unexpected implicit type
 *              conversions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-3-2
 *       scope/single-translation-unit
 *       correctness
 *       readability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from UnaryPlusExpr e
where not e.isFromUninstantiatedTemplate(_)
select e, "Use of built-in unary '+' operator."
