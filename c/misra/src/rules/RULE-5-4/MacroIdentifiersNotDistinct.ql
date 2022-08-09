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

from Macro m, Macro m2
where
  not isExcluded(m, Declarations1Package::macroIdentifiersNotDistinctQuery()) and
  not m = m2 and
  (
    if m.getName().length() >= 64
    then m.getName().substring(0, 62) = m2.getName().substring(0, 62)
    else m.getName() = m2.getName()
  ) and
  //reduce double report since both macros are in alert, arbitrary ordering
  m.getLocation().getStartLine() >= m2.getLocation().getStartLine()
select m, "Nondistinct macro identifer used " + m.getName() + " compared to $@.", m2, m2.getName()
