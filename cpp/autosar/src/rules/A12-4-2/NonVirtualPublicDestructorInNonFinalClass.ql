/**
 * @id cpp/autosar/non-virtual-public-destructor-in-non-final-class
 * @name A12-4-2: If a public destructor of a class is non-virtual, then the class should be declared final
 * @description If a public destructor of a class is non-virtual, then the class should be declared
 *              final.  If a public destructor of a class is non-virtual, then the class should be
 *              declared final to prevent it from being used as a base class.  A base class with a
 *              public non-virtual destructor will not invoke the destructors of derived classes
 *              when these derived classes are destroyed through a pointer or reference to the base
 *              class.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a12-4-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

predicate isPublicNonVirtual(Destructor d) { d.isPublic() and not d.isVirtual() }

from Destructor d
where
  not isExcluded(d, VirtualFunctionsPackage::nonVirtualPublicDestructorInNonFinalClassQuery()) and
  isPublicNonVirtual(d) and
  not d.getDeclaringType().isFinal()
select d, "Public non-virtual destructor of a non-final base class " + d.getDeclaringType() + "."
