/**
 * @id c/misra/compatible-declaration-function-defined
 * @name RULE-8-4: A compatible declaration shall be visible when a function with external linkage is defined
 * @description A compatible declaration shall be visible when a function with external linkage is
 *              defined, otherwise program behaviour may be undefined.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-4
 *       readability
 *       maintainability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers
import codingstandards.cpp.Compatible

from FunctionDeclarationEntry f1
where
  not isExcluded(f1, Declarations4Package::compatibleDeclarationFunctionDefinedQuery()) and
  f1.isDefinition() and
  f1.getDeclaration() instanceof ExternalIdentifiers and
  //no declaration matches exactly
  (
    not exists(FunctionDeclarationEntry f2 |
      not f2.isDefinition() and
      f2.getDeclaration() = f1.getDeclaration()
    )
    or
    //or one exists that is close but incompatible in some way
    exists(FunctionDeclarationEntry f2 |
      f1.getName() = f2.getName() and
      not f2.isDefinition() and
      f2.getDeclaration() = f1.getDeclaration() and
      //return types differ
      (
        not typesCompatible(f1.getType(), f2.getType())
        or
        //parameter types differ
        parameterTypesIncompatible(f1, f2)
        or
        //parameter names differ
        parameterNamesIncompatible(f1, f2)
      )
    )
  )
select f1, "No separate compatible declaration found for this definition."
