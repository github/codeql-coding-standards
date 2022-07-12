/**
 * @id cpp/autosar/global-unsized-operator-delete-not-defined
 * @name A18-5-4: Unsized 'operator delete' must be defined globally if sized 'operator delete' is defined globally
 * @description If a project has the sized version of operator 'delete' globally defined, then the
 *              unsized version shall be defined.
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

from OperatorDelete sized_delete
where
  not isExcluded(sized_delete, DeclarationsPackage::globalUnsizedOperatorDeleteNotDefinedQuery()) and
  sized_delete.isSizeDelete() and
  not exists(OperatorDelete od | sized_delete.isNoThrowDelete() = od.isNoThrowDelete() |
    not od.isSizeDelete()
  )
select sized_delete,
  "Sized function '" + sized_delete.getName() + "' defined globally without unsized version."
