/**
 * @id cpp/autosar/type-defined-as-struct-is-does-not-inherit-from-struct-or-class
 * @name A11-0-2: A type defined as struct shall not inherit from another struct or class
 * @description It is consistent with developer expectations that a struct is only an aggregate data
 *              type, without class-like features.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a11-0-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import NonUnionStruct

from NonUnionStruct s
where
  not isExcluded(s, ClassesPackage::typeDefinedAsStructIsDoesNotInheritFromStructOrClassQuery()) and
  exists(ClassDerivation cd | cd = s.getADerivation())
select s, "The struct $@ is derived from another class or struct.", s, s.getName()
