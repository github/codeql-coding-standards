/**
 * @id cpp/misra/function-contain-unreachable-statements
 * @name RULE-0-0-1: A function shall not contain unreachable statements
 * @description Unreachable statements can indicate a mistake on the part of the programmer.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-0-0-1
 *       scope/single-translation-unit
 *       readability
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from Expr x
where not isExcluded(x, DeadCodePackage::functionContainUnreachableStatementsQuery())
select x, "none"
