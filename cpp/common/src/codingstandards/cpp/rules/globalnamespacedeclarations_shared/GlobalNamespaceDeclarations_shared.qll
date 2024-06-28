/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class GlobalNamespaceDeclarations_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof GlobalNamespaceDeclarations_sharedSharedQuery }

query predicate problems(DeclarationEntry e, string message) {
  not isExcluded(e, getQuery()) and
  e.getDeclaration().getNamespace() instanceof GlobalNamespace and
  e.getDeclaration().isTopLevel() and
  not exists(Function f | f = e.getDeclaration() | f.hasGlobalName("main") or f.hasCLinkage()) and
  message =
    "Declaration " + e.getName() +
      " is in the global namespace and is not a main, a namespace, or an extern \"C\" declaration."
}
