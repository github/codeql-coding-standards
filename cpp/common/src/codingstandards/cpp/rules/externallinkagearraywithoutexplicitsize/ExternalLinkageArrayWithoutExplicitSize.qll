/**
 * Provides a library with a `problems` predicate for the following issue:
 * Introducing a function or object with external linkage outside of a header file can
 * cause developer confusion about its translation unit access semantics.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Linkage

abstract class ExternalLinkageArrayWithoutExplicitSizeSharedQuery extends Query { }

Query getQuery() { result instanceof ExternalLinkageArrayWithoutExplicitSizeSharedQuery }

query predicate problems(DeclarationEntry declEntry, string message) {
  exists(Variable v, ArrayType arrayType |
    not isExcluded(declEntry, getQuery()) and
    message =
      "The declared array '" + declEntry.getName() +
        "' with external linkage doesn't specify the size explicitly." and
    hasExternalLinkage(v) and
    not arrayType.hasArraySize() and
    // Holds is if declEntry is an array variable declaration (not a definition)
    v.getADeclarationEntry() = declEntry and
    not declEntry.isDefinition() and
    arrayType = v.getType().stripTopLevelSpecifiers()
  )
}
