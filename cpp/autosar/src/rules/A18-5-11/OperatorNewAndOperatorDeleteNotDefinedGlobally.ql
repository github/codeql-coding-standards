/**
 * @id cpp/autosar/operator-new-and-operator-delete-not-defined-globally
 * @name A18-5-11: 'operator new' and 'operator delete' shall be globally defined together
 * @description Use of a global 'operator new' function implies the use of a custom memory
 *              allocator, which should have a corresponding memory deallocator implemented in a
 *              global 'operator delete' function.
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

class GlobalFunction extends Function {
  GlobalFunction() { getNamespace() instanceof GlobalNamespace and not isMember() }
}

from GlobalFunction operator_new
where
  not isExcluded(operator_new,
    DeclarationsPackage::operatorNewAndOperatorDeleteNotDefinedGloballyQuery()) and
  operator_new.hasName("operator new") and
  not exists(GlobalFunction operator_delete | operator_delete.hasName("operator delete"))
select operator_new,
  "Global function  '" + operator_new.getName() + "' defined without 'operator delete'."
