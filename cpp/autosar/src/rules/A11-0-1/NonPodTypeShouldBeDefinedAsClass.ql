/**
 * @id cpp/autosar/non-pod-type-should-be-defined-as-class
 * @name A11-0-1: A non-POD type should be defined as class
 * @description The class specifier forces the type to provide private access control for all its
 *              members by default. This is consistent with developer expectations, because it is
 *              expected that a class has its invariant, interface and could provide custom-defined
 *              constructors.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a11-0-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Typehelpers

from Struct s
where
  not isExcluded(s, ClassesPackage::nonPodTypeShouldBeDefinedAsClassQuery()) and
  not s.isPod()
select s, "Non-POD type defined as struct instead of class."
