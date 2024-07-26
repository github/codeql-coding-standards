/**
 * Provides a library with a `problems` predicate for the following issue:
 * The only declarations in the global namespace should be main, namespace declarations
 * and extern "C" declarations.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class GlobalNamespaceDeclarationsSharedQuery extends Query { }

Query getQuery() { result instanceof GlobalNamespaceDeclarationsSharedQuery }

query predicate problems(DeclarationEntry e, string message) {
  not isExcluded(e, getQuery()) and
  e.getDeclaration().getNamespace() instanceof GlobalNamespace and
  e.getDeclaration().isTopLevel() and
  not exists(Function f | f = e.getDeclaration() | f.hasGlobalName("main") or f.hasCLinkage()) and
  message =
    "Declaration " + e.getName() +
      " is in the global namespace and is not a main, a namespace, or an extern \"C\" declaration."
}
