/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CsignalTypesUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof CsignalTypesUsed_sharedSharedQuery }

query predicate problems(TypeMention tm, string message) {
  exists(UserType ut |
    not isExcluded(tm, getQuery()) and
    ut = tm.getMentionedType() and
    ut.hasGlobalOrStdName("sig_atomic_t") and
    message = "Use of <csignal> type '" + ut.getQualifiedName() + "'."
  )
}
