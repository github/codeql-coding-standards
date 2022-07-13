/**
 * @id cpp/autosar/trivial-accessor-and-mutator-functions-not-inlined
 * @name A3-1-6: Trivial accessor and mutator functions should be inlined
 * @description Trivial accessor and mutator functions that are not inlined take up space and time.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a3-1-6
 *       readability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class

from MemberFunction mf, string kind
where
  not isExcluded(mf, FunctionsPackage::trivialAccessorAndMutatorFunctionsNotInlinedQuery()) and
  // The member function is defined outside the class body and thus is not inlined.
  not exists(FunctionDeclarationEntry fde |
    fde = mf.getClassBodyDeclarationEntry() and
    fde.isDefinition()
  ) and
  (
    mf instanceof TrivialAccessor and kind = "accessor"
    or
    mf instanceof TrivialMutator and kind = "mutator"
  )
select mf,
  "Trivial " + kind + " function " + mf.getQualifiedName() +
    " is defined outside the class body of $@.", mf.getDeclaringType(),
  mf.getDeclaringType().getName()
