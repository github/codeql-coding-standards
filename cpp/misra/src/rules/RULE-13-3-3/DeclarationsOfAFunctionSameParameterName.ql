/**
 * @id cpp/misra/declarations-of-a-function-same-parameter-name
 * @name RULE-13-3-3: The parameters in all declarations or overrides of a function shall either be unnamed or have identical names
 * @description Parameters in some number of declarations or overrides of a function that do not
 *              have identical names can lead to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-3-3
 *       maintainability
 *       readability
 *       scope/system
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.Compatible

predicate parameterNamesUnmatchedOverrides(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  pragma[only_bind_into](f1).getFunction().(MemberFunction).getAnOverridingFunction*() =
    pragma[only_bind_into](f2).getFunction() and
  exists(string p1Name, string p2Name, int i |
    p1Name = f1.getParameterDeclarationEntry(i).getName() and
    p2Name = f2.getParameterDeclarationEntry(i).getName()
  |
    not p1Name = p2Name
  )
}

from FunctionDeclarationEntry f1, FunctionDeclarationEntry f2, string case
where
  not isExcluded(f1, Declarations1Package::declarationsOfAFunctionSameParameterNameQuery()) and
  not isExcluded(f2, Declarations1Package::declarationsOfAFunctionSameParameterNameQuery()) and
  not f1 = f2 and
  (
    f1.getDeclaration() = f2.getDeclaration() and
    parameterNamesUnmatched(f1, f2) and
    case = "re-declaration"
    or
    parameterNamesUnmatchedOverrides(f1, f2) and
    case = "override"
  )
select f1,
  "The parameter names of " + case + " of $@ do" + " not use the same names as declaration $@", f1,
  f1.getName(), f2, f2.getName()
