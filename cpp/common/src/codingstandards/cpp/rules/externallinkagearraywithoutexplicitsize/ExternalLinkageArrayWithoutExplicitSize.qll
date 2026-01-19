/**
 * Provides a library with a `problems` predicate for the following issue:
 * Declaring an array with external linkage without its size being explicitly specified can disallow consistency and range checks on the array size and usage.
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
    // Holds if declEntry is an array variable declaration (not a definition)
    v.getADeclarationEntry() = declEntry and
    not declEntry.isDefinition() and
    arrayType = declEntry.getType().stripTopLevelSpecifiers()
  )
}
