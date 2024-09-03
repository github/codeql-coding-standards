/**
 * Provides a library with a `problems` predicate for the following issue:
 * Streams and file I/O have a large number of unspecified, undefined, and
 * implementation-defined behaviours associated with them.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CstdioTypesUsedSharedQuery extends Query { }

Query getQuery() { result instanceof CstdioTypesUsedSharedQuery }

query predicate problems(TypeMention tm, string message) {
  exists(UserType ut |
    not isExcluded(tm, getQuery()) and
    ut = tm.getMentionedType() and
    ut.hasGlobalOrStdName(["FILE", "fpos_t"]) and
    // Not in the standard library
    exists(tm.getFile().getRelativePath()) and
    // Not in our tests copy of the standard library
    not tm.getFile().getRelativePath() =
      ["includes/standard-library/stddef.h", "includes/standard-library/stdio.h"] and
    message = "Use of <cstdio> type '" + ut.getQualifiedName() + "'."
  )
}
