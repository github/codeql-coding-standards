/**
 * @id cpp/autosar/type-defined-as-struct-is-not-base-of-other-class-or-struct
 * @name A11-0-2: A type defined as struct shall not be a base of another struct or class
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

from NonUnionStruct s, Class c
where
  not isExcluded(s, ClassesPackage::typeDefinedAsStructIsNotBaseOfOtherClassOrStructQuery()) and
  c = s.getADerivedClass()
select s, "The struct $@ is is used as the base in the derivation of $@.", s, s.getName(), c,
  c.getName()
