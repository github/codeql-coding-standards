/**
 * @id c/cert/incompatible-function-declarations
 * @name DCL40-C: Do not create incompatible declarations of the same function or object
 * @description Declaring incompatible functions, in other words same named function of different
 *              return types or with different numbers of parameters or parameter types, then
 *              accessing those functions can lead to undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/dcl40-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/obligation/rule
 *       external/cert/priority/p2
 *       external/cert/level/l3
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.types.Compatible
import ExternalIdentifiers

predicate interestedInFunctions(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  not f1 = f2 and
  f1.getDeclaration() = f2.getDeclaration() and
  f1.getName() = f2.getName()
}

from ExternalIdentifiers d, FunctionDeclarationEntry f1, FunctionDeclarationEntry f2
where
  not isExcluded(f1, Declarations2Package::incompatibleFunctionDeclarationsQuery()) and
  not isExcluded(f2, Declarations2Package::incompatibleFunctionDeclarationsQuery()) and
  not f1 = f2 and
  f1.getDeclaration() = d and
  f2.getDeclaration() = d and
  f1.getName() = f2.getName() and
  (
    //return type check
    not FunctionDeclarationTypeEquivalence<TypesCompatibleConfig, interestedInFunctions/2>::equalReturnTypes(f1,
      f2)
    or
    //parameter type check
    not FunctionDeclarationTypeEquivalence<TypesCompatibleConfig, interestedInFunctions/2>::equalParameterTypes(f1,
      f2)
  ) and
  // Apply ordering on start line, trying to avoid the optimiser applying this join too early
  // in the pipeline
  exists(int f1Line, int f2Line |
    f1.getLocation().hasLocationInfo(_, f1Line, _, _, _) and
    f2.getLocation().hasLocationInfo(_, f2Line, _, _, _) and
    f1Line >= f2Line
  )
select f1, "The object $@ is not compatible with re-declaration $@", f1, f1.getName(), f2,
  f2.getName()
