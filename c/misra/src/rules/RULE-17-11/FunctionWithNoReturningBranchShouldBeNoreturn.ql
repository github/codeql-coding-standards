/**
 * @id c/misra/function-with-no-returning-branch-should-be-noreturn
 * @name RULE-17-11: A function without a branch that returns shall be declared with _Noreturn
 * @description Functions which cannot return should be declared with _Noreturn.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-17-11
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Noreturn

from Function f
where
  not isExcluded(f, NoReturnPackage::functionWithNoReturningBranchShouldBeNoreturnQuery()) and
  not f instanceof NoreturnFunction and
  not mayReturn(f) and
  f.hasDefinition() and
  not f.getName() = "main" and // Allowed exception; _Noreturn main() is undefined behavior.
  // Harden against c++ cases.
  not f.isFromUninstantiatedTemplate(_) and
  not f.isDeleted() and
  not f.isCompilerGenerated()
select f, "The function " + f.getName() + " cannot return and should be declared as _Noreturn."
