/**
 * Provides a library which includes a `problems` predicate for reporting declarations that modify standard namespaces.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.StdNamespace

abstract class NonStandardEntitiesInStandardNamespacesSharedQuery extends Query { }

Query getQuery() { result instanceof NonStandardEntitiesInStandardNamespacesSharedQuery }

private class PosixNamespace extends Namespace {
  PosixNamespace() {
    this.hasName("posix") and this.getParentNamespace() instanceof GlobalNamespace
  }
}

private Namespace getStandardNamespace(DeclarationEntry de) {
  result = de.getDeclaration().getNamespace().getParentNamespace*() and
  (
    result instanceof StdNS
    or
    result instanceof PosixNamespace
  )
}

query predicate problems(Declaration d, string message) {
  not isExcluded(d, getQuery()) and
  exists(DeclarationEntry de, Namespace ns | de.getDeclaration() = d |
    de.getDeclaration().isTopLevel() and
    ns = getStandardNamespace(de) and
    not exists(ClassTemplateSpecialization tc |
      tc = de.getDeclaration() and
      tc.getATemplateArgument() instanceof UserType
    ) and
    message =
      "Declaration " + d.getName() + " modifies the standard namespace " + ns.getName() + "."
  )
}
