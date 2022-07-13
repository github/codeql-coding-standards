/**
 * @id cpp/autosar/global-sized-operator-delete-not-defined
 * @name A18-5-4: Sized 'operator delete' must be defined globally if unsized 'operator delete' is defined globally
 * @description If a project has the unsized version of operator 'delete' globally defined, then the
 *              sized version shall be defined.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-5-4
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import OperatorDelete

from OperatorDelete unsized_delete
where
  not isExcluded(unsized_delete, DeclarationsPackage::globalSizedOperatorDeleteNotDefinedQuery()) and
  not unsized_delete.isSizeDelete() and
  not exists(OperatorDelete od | unsized_delete.isNoThrowDelete() = od.isNoThrowDelete() |
    od.isSizeDelete()
  )
select unsized_delete,
  "Unsized function '" + unsized_delete.getName() + "' defined globally without sized version."
