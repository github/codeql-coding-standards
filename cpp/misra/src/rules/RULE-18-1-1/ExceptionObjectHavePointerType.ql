/**
 * @id cpp/misra/exception-object-have-pointer-type
 * @name RULE-18-1-1: An exception object shall not have pointer type
 * @description An exception object shall not have pointer type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-1-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.exceptionobjecthavepointertype_shared.ExceptionObjectHavePointerType_shared

class ExceptionObjectHavePointerTypeQuery extends ExceptionObjectHavePointerType_sharedSharedQuery {
  ExceptionObjectHavePointerTypeQuery() {
    this = ImportMisra23Package::exceptionObjectHavePointerTypeQuery()
  }
}
