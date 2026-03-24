/**
 * Provides a configurable module UnionKeywordUsed with a `problems` predicate
 * for the following issue:
 * Unions shall not be used. Tagged unions can be used if 'std::variant' is not
 * available.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

signature module UnionKeywordUsedConfigSig {
  Query getQuery();
}

module UnionKeywordUsed<UnionKeywordUsedConfigSig Config> {
  query predicate problems(Element e, string message) {
    not isExcluded(e, Config::getQuery()) and message = "<replace with problem alert message for >"
  }
}
