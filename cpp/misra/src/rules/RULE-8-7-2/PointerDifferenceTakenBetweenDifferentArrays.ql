/**
 * @id cpp/misra/pointer-difference-taken-between-different-arrays
 * @name RULE-8-7-2: Subtraction between pointers shall only be applied to ones that address elements of the same array
 * @description Pointer difference should be taken from pointers that belong to a same array.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-7-2
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, Memory2Package::pointerDifferenceTakenBetweenDifferentArraysQuery()) and
select
