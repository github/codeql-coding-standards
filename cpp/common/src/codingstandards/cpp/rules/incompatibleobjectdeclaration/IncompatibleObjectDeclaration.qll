/**
 * Provides a configurable module IncompatibleObjectDeclaration with a `problems` predicate
 * for the following issue:
 * Declaring incompatible objects, in other words same named objects of different
 * types, then accessing those objects can lead to undefined behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Identifiers
import codingstandards.cpp.types.Compatible

signature module IncompatibleObjectDeclarationConfigSig {
  Query getQuery();
}

class VariableDeclarationEntryExternal extends VariableDeclarationEntry {
  VariableDeclarationEntryExternal() { this.getDeclaration() instanceof ExternalIdentifiers }
}

predicate relevantTypes(Type a, Type b) {
  exists(VariableDeclarationEntryExternal varA, VariableDeclarationEntryExternal varB |
    not varA = varB and
    varA.getVariable().getName() = varB.getVariable().getName() and
    a = varA.getType() and
    b = varB.getType()
  )
}

module IncompatibleObjectDeclaration<IncompatibleObjectDeclarationConfigSig Config> {
  query predicate problems(
    VariableDeclarationEntryExternal decl1, string message, VariableDeclarationEntryExternal decl2,
    string secondMessage
  ) {
    not isExcluded(decl1, Config::getQuery()) and
    not isExcluded(decl2, Config::getQuery()) and
    not TypeEquivalence<TypesCompatibleConfig, relevantTypes/2>::equalTypes(decl1.getType(),
      decl2.getType()) and
    not decl1 = decl2 and
    decl1.getLocation().getStartLine() >= decl2.getLocation().getStartLine() and
    decl1.getVariable().getName() = decl2.getVariable().getName() and
    secondMessage = decl2.getName() and
    message = "The object is not compatible with a re-declaration $@."
  }
}
