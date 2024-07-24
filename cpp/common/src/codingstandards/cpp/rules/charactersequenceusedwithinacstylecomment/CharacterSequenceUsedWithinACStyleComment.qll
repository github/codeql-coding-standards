/**
 * Provides a library with a `problems` predicate for the following issue:
 * The presence of a nested /* comment can indicate accidentally commented out code.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CharacterSequenceUsedWithinACStyleCommentSharedQuery extends Query { }

Query getQuery() { result instanceof CharacterSequenceUsedWithinACStyleCommentSharedQuery }

query predicate problems(CStyleComment c, string message) {
  not isExcluded(c, getQuery()) and
  exists(c.getContents().regexpFind("./\\*", _, _)) and
  message = "C-style /* comment includes nested /*."
}
