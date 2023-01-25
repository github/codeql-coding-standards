/**
 * @id c/misra/declarations-of-a-function-same-name-and-type
 * @name RULE-8-3: All declarations of a function shall use the same names and type qualifiers
 * @description Using different types across the same declarations disallows strong type checking
 *              and can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-3
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Compatible

from FunctionDeclarationEntry f1, FunctionDeclarationEntry f2, string case
where
  not isExcluded(f1, Declarations4Package::declarationsOfAFunctionSameNameAndTypeQuery()) and
  not isExcluded(f2, Declarations4Package::declarationsOfAFunctionSameNameAndTypeQuery()) and
  not f1 = f2 and
  f1.getDeclaration() = f2.getDeclaration() and
  //return type check
  (
    not typesCompatible(f1.getType(), f2.getType()) and
    case = "return type"
    or
    //parameter type check
    parameterTypesIncompatible(f1, f2) and
    case = "parameter types"
    or
    //parameter name check
    parameterNamesIncompatible(f1, f2) and
    case = "parameter names"
  )
select f1, "The " + case + " of re-declaration of $@ is not compatible with declaration $@", f1,
  f1.getName(), f2, f2.getName()
