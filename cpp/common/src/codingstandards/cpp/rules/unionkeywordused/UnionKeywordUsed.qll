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

// A tagged union is a class or a struct
// that has exactly one union and exactly one enum with
// corresponding member variable that represents
// the data type in the union
class TaggedUnion extends UserType {
  TaggedUnion() {
    (this instanceof Class or this instanceof Struct) and
    count(Enum e | e.getParentScope() = this) = 1 and
    count(Union u | u.getParentScope() = this) = 1 and
    count(MemberVariable m, Enum e |
      m.getDeclaringType() = this and
      e.getDeclaringType() = this and
      m.getType().getName() = e.getName()
    ) = 1
  }
}

module UnionKeywordUsed<UnionKeywordUsedConfigSig Config> {
  query predicate problems(Union u, string message) {
    not isExcluded(u, Config::getQuery()) and
    not u.getParentScope() instanceof TaggedUnion and
    message = "'" + u.getName() + "' is not a tagged union."
  }
}
