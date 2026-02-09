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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.types.Compatible

predicate interestedInFunctions(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  not f1 = f2 and
  f1.getDeclaration() = f2.getDeclaration()
}

from FunctionDeclarationEntry f1, FunctionDeclarationEntry f2, string case, string pluralDo
where
  not isExcluded(f1, Declarations4Package::declarationsOfAFunctionSameNameAndTypeQuery()) and
  not isExcluded(f2, Declarations4Package::declarationsOfAFunctionSameNameAndTypeQuery()) and
  not f1 = f2 and
  f1.getDeclaration() = f2.getDeclaration() and
  //return type check
  (
    not FunctionDeclarationTypeEquivalence<TypeNamesMatchConfig, interestedInFunctions/2>::equalReturnTypes(f1,
      f2) and
    case = "return type" and
    pluralDo = "does"
    or
    //parameter type check
    not FunctionDeclarationTypeEquivalence<TypeNamesMatchConfig, interestedInFunctions/2>::equalParameterTypes(f1,
      f2) and
    case = "parameter types" and
    pluralDo = "do"
    or
    //parameter name check
    parameterNamesUnmatched(f1, f2) and
    case = "parameter names" and
    pluralDo = "do"
  )
select f1,
  "The " + case + " of re-declaration of $@ " + pluralDo +
    " not use the same type names as declaration $@", f1, f1.getName(), f2, f2.getName()
