/**
 * @id cpp/autosar/operator-new-and-operator-delete-not-defined-locally
 * @name A18-5-11: 'operator new' and 'operator delete' shall be locally defined together
 * @description A class implementation of 'operator new' implies the use of a custom memory
 *              allocator, which should have a corresponding memory deallocator member-function
 *              implemented in 'operator delete' of the same class.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-5-11
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from MemberFunction operator_new, Class c
where
  not isExcluded(operator_new) and
  not isExcluded(c, DeclarationsPackage::operatorNewAndOperatorDeleteNotDefinedLocallyQuery()) and
  operator_new.hasName("operator new") and
  operator_new.getDeclaringType() = c and
  not exists(MemberFunction mf | mf.getDeclaringType() = c | mf.getName() = "operator delete")
select operator_new, "Class $@ implements 'operator new' but not 'operator delete'", c, c.getName()
