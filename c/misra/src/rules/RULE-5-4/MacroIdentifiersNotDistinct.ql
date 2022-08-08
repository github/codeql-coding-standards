/**
 * @id c/misra/macro-identifiers-not-distinct
 * @name RULE-5-4: Macro identifiers shall be distinct
 * @description Declaring multiple macros with the same name leads to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-4
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Macro m
where
  not isExcluded(m, Declarations1Package::macroIdentifiersNotDistinctQuery()) and
  exists(Macro m2 |
    not m = m2 and
    if m.getName().length() >= 64
    then m.getName().substring(0, 62) = m2.getName().substring(0, 62)
    else m.getName() = m2.getName()
  )
select m, "Nondistinct macro identifer used " + m.getName() + " ."
