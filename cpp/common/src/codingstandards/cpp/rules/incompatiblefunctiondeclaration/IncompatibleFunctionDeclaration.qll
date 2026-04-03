/**
 * Provides a configurable module IncompatibleFunctionDeclaration with a `problems` predicate
 * for the following issue:
 * Declaring incompatible functions, in other words same named function of different
 * return types or with different numbers of parameters or parameter types, then
 * accessing those functions can lead to undefined behaviour.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Identifiers
import codingstandards.cpp.types.Compatible

predicate interestedInFunctions(
  FunctionDeclarationEntry f1, FunctionDeclarationEntry f2, ExternalIdentifiers d1,
  ExternalIdentifiers d2
) {
  not f1 = f2 and
  d1 = f1.getDeclaration() and
  d2 = f2.getDeclaration() and
  f1.getName() = f2.getName()
}

predicate interestedInFunctions(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  interestedInFunctions(f1, f2, _, _)
}

module FuncDeclEquiv =
  FunctionDeclarationTypeEquivalence<TypesCompatibleConfig, interestedInFunctions/2>;

signature module IncompatibleFunctionDeclarationConfigSig {
  Query getQuery();
}

module IncompatibleFunctionDeclaration<IncompatibleFunctionDeclarationConfigSig Config> {
  query predicate problems(
    FunctionDeclarationEntry f1, string message, FunctionDeclarationEntry f2, string secondMessage
  ) {
    exists(ExternalIdentifiers d1, ExternalIdentifiers d2 |
      not isExcluded(f1, Config::getQuery()) and
      not isExcluded(f2, Config::getQuery()) and
      interestedInFunctions(f1, f2, d1, d2) and
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
      ) and
      secondMessage = f2.getName() and
      message = "The object is not compatible with a re-declaration $@."
    )
  }
}
