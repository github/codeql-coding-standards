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
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Macro

from Macro m
where
  not isExcluded(m, Preprocessor2Package::moreThanOneHashOperatorInMacroDefinitionQuery()) and
  exists(StringizingOperator one, TokenPastingOperator two |
    one.getMacro() = m and
    two.getMacro() = m and
    one.getOffset() < two.getOffset()
  )
select m, "Macro definition uses an # operator followed by a ## operator."
