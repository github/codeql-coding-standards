/**
 * Provides a library with a `problems` predicate for the following issue:
 * Signal handling contains implementation-defined and undefined behaviour.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CsignalTypesUsedSharedQuery extends Query { }

Query getQuery() { result instanceof CsignalTypesUsedSharedQuery }

query predicate problems(TypeMention tm, string message) {
  exists(UserType ut |
    not isExcluded(tm, getQuery()) and
    ut = tm.getMentionedType() and
    ut.hasGlobalOrStdName("sig_atomic_t") and
    message = "Use of <csignal> type '" + ut.getQualifiedName() + "'."
  )
}
