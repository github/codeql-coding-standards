/**
 * @id cpp/autosar/type-defined-as-struct-has-no-methods
 * @name A11-0-2: A type defined as struct shall not provide any special member functions or methods
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

from NonUnionStruct s, Declaration d
where
  not isExcluded(s, ClassesPackage::typeDefinedAsStructHasNoMethodsQuery()) and
  not isExcluded(d, ClassesPackage::typeDefinedAsStructHasNoMethodsQuery()) and
  d = s.getAMember() and
  not (
    d.(MemberFunction).isCompilerGenerated()
    or
    d instanceof Field
  )
select s, "Declaration of $@ in struct $@ is not a data field.", d, d.getName(), s, s.getName()
