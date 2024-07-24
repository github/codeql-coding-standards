/**
 * @id cpp/misra/global-unsized-operator-delete-shall-be-defined
 * @name RULE-21-6-4: Unsized 'operator delete' must be defined globally if sized 'operator delete' is defined globally
 * @description If a project defines the sized version of a global operator delete, then the unsized
 *              version shall be defined.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6-4
 *       maintainability
 *       scope/system
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.globalunsizedoperatordeletenotdefined.GlobalUnsizedOperatorDeleteNotDefined

class GlobalUnsizedOperatorDeleteShallBeDefinedQuery extends GlobalUnsizedOperatorDeleteNotDefinedSharedQuery
{
  GlobalUnsizedOperatorDeleteShallBeDefinedQuery() {
    this = ImportMisra23Package::globalUnsizedOperatorDeleteShallBeDefinedQuery()
  }
}
