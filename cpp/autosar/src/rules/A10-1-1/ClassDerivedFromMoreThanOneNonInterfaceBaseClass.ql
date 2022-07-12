/**
 * @id cpp/autosar/class-derived-from-more-than-one-non-interface-base-class
 * @name A10-1-1: Class shall not be derived from more than one base class which is not an interface class
 * @description Classes should not be derived from more than one non-interface base class to avoid
 *              exposing multiple implementations to derived classes.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a10-1-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Inheritance

from Class c, ClassDerivation cd1, ClassDerivation cd2
where
  not isExcluded(c, InheritancePackage::classDerivedFromMoreThanOneNonInterfaceBaseClassQuery()) and
  // two separate class derivations by the same Class
  // compare derivations by index to select combinations instead of permutations
  cd1.getIndex() < cd2.getIndex() and
  cd1.getDerivedClass() = c and
  cd2.getDerivedClass() = c and
  // where the class derivations are both not from interface classes
  not cd1.getBaseClass() instanceof AutosarInterfaceClass and
  not cd2.getBaseClass() instanceof AutosarInterfaceClass
select c, "Class derives from more than one non-abstract base class ($@ and $@)", cd1,
  cd1.getBaseClass().getName(), cd2, cd2.getBaseClass().getName()
