/**
 * @id cpp/autosar/more-than-one-occurrence-hash-operator-in-macro-definition
 * @name M16-3-1: There shall be at most one occurrence of the # or ## operators in a single macro definition
 * @description The order of evaluation for the '#' and '##' operators may differ between compilers,
 *              which can cause unexpected behaviour if more than one '#' or '##' operator is used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Macro

from Macro m
where
  count(StringizingOperator op | op.getMacro() = m | op) > 1
  or
  count(any(TokenPastingOperator op | op.getMacro() = m | op.getOffset())) > 1
  or
  exists(StringizingOperator one, TokenPastingOperator two |
    one.getMacro() = m and
    two.getMacro() = m
  ) and
  not isExcluded(m, MacrosPackage::moreThanOneOccurrenceHashOperatorInMacroDefinitionQuery())
select m, "Macro definition uses the # or ## operator more than once."
