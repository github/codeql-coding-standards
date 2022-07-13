/**
 * @id cpp/autosar/null-thrown-explicitly
 * @name M15-1-2: NULL shall not be thrown explicitly
 * @description Throwing NULL is equivalent to throwing integer 0, which will only be handled by
 *              integer handlers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m15-1-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.enhancements.MacroEnhacements

from ThrowExpr te
where
  not isExcluded(te, Exceptions1Package::nullThrownExplicitlyQuery()) and
  te.getExpr() instanceof MacroEnhancements::NULL
select te, "NULL thrown explicitly."
