/**
 * @id cpp/autosar/destructor-of-a-base-class-not-public-virtual
 * @name A12-4-1: Destructor of a base class shall be public virtual, public override or protected non-virtual
 * @description Destructor of a base class shall be public virtual or public override to ensure that
 *              destructors for derived types are invoked when the derived types are destroyed
 *              through a pointer or reference to its base class.  If destruction through a base
 *              class pointer or reference is prohibited, the destructor of the base class should be
 *              protected.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a12-4-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class

predicate isPublicOverride(Destructor d) { d.isPublic() and d.hasSpecifier("override") }

predicate isPublicVirtual(Destructor d) { d.isPublic() and d.isVirtual() }

predicate isProtectedNonVirtual(Destructor d) { d.isProtected() and not d.isVirtual() }

from Destructor d
where
  not isExcluded(d, VirtualFunctionsPackage::destructorOfABaseClassNotPublicVirtualQuery()) and
  isPossibleBaseClass(d.getDeclaringType(), _) and
  (not isPublicOverride(d) and not isProtectedNonVirtual(d) and not isPublicVirtual(d))
// Report the declaration entry in the class body, as that is where the access specifier should be set
select getDeclarationEntryInClassDeclaration(d),
  "Destructor of base class " + d.getDeclaringType() +
    " is not declared as public virtual, public override, or protected non-virtual."
