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
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.types.Compatible
import ExternalIdentifiers

predicate interestedInFunctions(
  FunctionDeclarationEntry f1, FunctionDeclarationEntry f2, ExternalIdentifiers d
) {
  not f1 = f2 and
  d = f1.getDeclaration() and
  d = f2.getDeclaration()
}

predicate interestedInFunctions(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  interestedInFunctions(f1, f2, _)
}

module FuncDeclEquiv =
  FunctionDeclarationTypeEquivalence<TypesCompatibleConfig, interestedInFunctions/2>;

from ExternalIdentifiers d, FunctionDeclarationEntry f1, FunctionDeclarationEntry f2
where
  not isExcluded(f1, Declarations2Package::incompatibleFunctionDeclarationsQuery()) and
  not isExcluded(f2, Declarations2Package::incompatibleFunctionDeclarationsQuery()) and
  interestedInFunctions(f1, f2, d) and
  (
    //return type check
    not FuncDeclEquiv::equalReturnTypes(f1, f2)
    or
    //parameter type check
    not FuncDeclEquiv::equalParameterTypes(f1, f2)
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
