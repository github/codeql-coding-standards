/**
 * @id cpp/misra/global-sized-operator-delete-shall-be-defined
 * @name RULE-21-6-4: Sized 'operator delete' must be defined globally if unsized 'operator delete' is defined globally
 * @description If a project defines the unsized version of a global operator delete, then the sized
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
import codingstandards.cpp.rules.globalsizedoperatordeletenotdefined_shared.GlobalSizedOperatorDeleteNotDefined_shared

class GlobalSizedOperatorDeleteShallBeDefinedQuery extends GlobalSizedOperatorDeleteNotDefined_sharedSharedQuery {
  GlobalSizedOperatorDeleteShallBeDefinedQuery() {
    this = ImportMisra23Package::globalSizedOperatorDeleteShallBeDefinedQuery()
  }
}
