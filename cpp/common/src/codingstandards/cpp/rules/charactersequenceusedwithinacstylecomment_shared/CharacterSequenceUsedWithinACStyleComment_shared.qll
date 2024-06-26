/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CharacterSequenceUsedWithinACStyleComment_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof CharacterSequenceUsedWithinACStyleComment_sharedSharedQuery }

query predicate problems(CStyleComment c, string message) {
  not isExcluded(c, getQuery()) and
  exists(c.getContents().regexpFind("./\\*", _, _)) and
  message = "C-style /* comment includes nested /*."
}
