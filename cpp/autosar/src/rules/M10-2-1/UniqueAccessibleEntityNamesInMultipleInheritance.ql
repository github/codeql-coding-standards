/**
 * @id cpp/autosar/unique-accessible-entity-names-in-multiple-inheritance
 * @name M10-2-1: All accessible entity names within a multiple inheritance hierarchy should be unique
 * @description Duplicate entity names in a multiple inheritance hierarchy can lead to ambiguity in
 *              variable and virtual function access.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m10-2-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

class MemberEntityDeclaration extends Declaration {
  MemberEntityDeclaration() {
    (this instanceof MemberVariable or this instanceof MemberFunction) and
    not this instanceof Operator and
    not this instanceof Constructor and
    not this instanceof Destructor
  }

  predicate isPublicOrProtected() { this.hasSpecifier("public") or this.hasSpecifier("protected") }

  predicate isAccessibleFromClass(Class c) {
    // if "this" MemberEntityDeclaration is a member of 'c'
    c.getAMember() = this
    or
    // else recursively follow parent class derivations if:
    // - the MemberEntityDeclaration instance is public or protected and
    // - the class derivation is public or protected
    exists(ClassDerivation cd |
      cd = c.getADerivation() and
      (cd.hasSpecifier("public") or cd.hasSpecifier("protected")) and
      this.isPublicOrProtected() and
      isAccessibleFromClass(cd.getBaseClass())
    )
  }
}

from MemberEntityDeclaration decl1, MemberEntityDeclaration decl2, Class derived
where
  not isExcluded(derived,
    InheritancePackage::uniqueAccessibleEntityNamesInMultipleInheritanceQuery()) and
  // where two differing member entity declarations are not declared by 'derived'
  decl1 != decl2 and
  decl1.getDeclaringType() != derived and
  decl2.getDeclaringType() != derived and
  // and the names of the declarations are the same
  decl1.getName() = decl2.getName() and
  // and the declaring types of both declarations are not in the same inheritance hierarchy
  not decl1.getDeclaringType().getABaseClass*() = decl2.getDeclaringType().getABaseClass*() and
  // and both declarations are accessible from 'derived'
  pragma[only_bind_into](decl1).isAccessibleFromClass(derived) and
  pragma[only_bind_into](decl2).isAccessibleFromClass(derived) and
  // and the declaring type name (DTN) of decl1 is less than the DTN of decl2 (remove permutations)
  decl1 =
    rank[1](MemberEntityDeclaration decl |
      decl = decl1 or decl = decl2
    |
      decl order by decl.getDeclaringType().getName()
    )
select derived,
  "Entities $@ and $@ are ambiguously accessible as '" + decl1.getName() +
    "' in the multiple inheritance hierarchy of class " + derived + ".", decl1,
  decl1.getQualifiedName(), decl2, decl2.getQualifiedName()
