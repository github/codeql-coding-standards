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
    //C99 states the first 63 characters of macro identifiers are significant
    //C90 states the first 31 characters of macro identifiers are significant and is not currently considered by this rule
    //ie an identifier differing on the 32nd character would be indistinct for C90 but distinct for C99
    //and is currently not reported by this rule
    if m.getName().length() >= 64
    then m.getName().prefix(63) = m2.getName().prefix(63)
    else m.getName() = m2.getName()
  ) and
  //reduce double report since both macros are in alert, arbitrary ordering
  m.getLocation().getStartLine() >= m2.getLocation().getStartLine()
select m, "Macro identifer " + m.getName() + " is nondistinct in first 63 characters, compared to $@.", m2, m2.getName()
