/**
 * @id c/misra/inline-function-not-declared-static-storage
 * @name RULE-8-10: An inline function shall be declared with the static storage class
 * @description Declaring an inline function with external linkage can lead to undefined or
 *              incorrect program behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-10
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers

from FunctionDeclarationEntry f
where
  not isExcluded(f, Declarations6Package::inlineFunctionNotDeclaredStaticStorageQuery()) and
  f.getFunction() instanceof InterestingIdentifiers and
  f.getFunction().isInline() and
  not f.hasSpecifier("static")
select f, "Inline function not explicitly declared static."
