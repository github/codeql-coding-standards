/**
 * Provides a library which includes a `problems` predicate for reporting declarations of reserved identifiers.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Naming
import codingstandards.cpp.CKeywords

abstract class DeclaredAReservedIdentifierSharedQuery extends Query { }

Query getQuery() { result instanceof DeclaredAReservedIdentifierSharedQuery }

query predicate problems(Element m, string message) {
  not isExcluded(m, getQuery()) and
  exists(string name |
    (
      m.(Macro).hasName(name) or
      m.(Declaration).hasGlobalName(name)
    ) and
    (
      Naming::Cpp14::hasStandardLibraryMacroName(name)
      or
      Naming::Cpp14::hasStandardLibraryObjectName(name)
      or
      Naming::Cpp14::hasStandardLibraryFunctionName(name)
      or
      name.regexpMatch("_[A-Z_].*")
      or
      name.regexpMatch("_.*") and m.(Declaration).hasGlobalName(name)
      or
      Keywords::isKeyword(name)
    ) and
    message = "Reserved identifier '" + name + "' is declared."
  )
}
