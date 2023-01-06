/**
 * @id c/misra/identifiers-not-distinct-from-macro-names
 * @name RULE-5-5: Identifiers shall be distinct from macro names
 * @description Reusing a macro name compared to the name of any other identifier can cause
 *              confusion and make code harder to read.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-5
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers

from Macro m, InterestingIdentifiers i, string mName, string iName
where
  not isExcluded(m, Declarations3Package::identifiersNotDistinctFromMacroNamesQuery()) and
  not isExcluded(i, Declarations3Package::identifiersNotDistinctFromMacroNamesQuery()) and
  mName = iName and
  (
    //C99 states the first 63 characters of macro identifiers are significant
    //C90 states the first 31 characters of macro identifiers are significant
    //C90 is not currently considered by this rule
    if m.getName().length() > 63 then mName = m.getName().prefix(63) else mName = m.getName()
  ) and
  if i.getName().length() > 63
  then iName = i.getSignificantNameComparedToMacro()
  else iName = i.getName()
select m, "Macro name is nonunique compared to $@.", i, i.getName()
