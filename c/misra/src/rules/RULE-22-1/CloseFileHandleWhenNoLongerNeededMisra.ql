/**
 * @id c/misra/close-file-handle-when-no-longer-needed-misra
 * @name RULE-22-1: File handles acquired with Standard Library functions shall be explicitly closed
 * @description File handles acquired with standard library functions should be released to avoid
 *              resource exhaustion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-1
 *       correctness
 *       security
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.closefilehandlewhennolongerneededshared.CloseFileHandleWhenNoLongerNeededShared

class CloseFileHandleWhenNoLongerNeededMisraQuery extends CloseFileHandleWhenNoLongerNeededSharedSharedQuery {
  CloseFileHandleWhenNoLongerNeededMisraQuery() {
    this = Memory2Package::closeFileHandleWhenNoLongerNeededMisraQuery()
  }
}
