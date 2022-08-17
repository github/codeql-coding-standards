/**
 * @id cpp/autosar/unions-used
 * @name A9-5-1: Unions shall not be used
 * @description Unions shall not be used.  Tagged untions can be used if std::variant is not
 *              available.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a9-5-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

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

from Union u
where
  not isExcluded(u, BannedSyntaxPackage::unionsUsedQuery()) and
  not u.getParentScope() instanceof TaggedUnion
select u, u.getName() + " is not a tagged union."
