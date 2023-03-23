/**
 * @id c/cert/close-files-when-they-are-no-longer-needed
 * @name FIO42-C: Close files when they are no longer needed
 * @description Open files must be closed before the lifetime of the last pointer to the file-object
 *              has ended to prevent resource exhaustion and data loss issues.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/fio42-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.closefilehandlewhennolongerneededshared.CloseFileHandleWhenNoLongerNeededShared

class CloseFilesWhenTheyAreNoLongerNeededQuery extends CloseFileHandleWhenNoLongerNeededSharedSharedQuery {
  CloseFilesWhenTheyAreNoLongerNeededQuery() {
    this = IO1Package::closeFilesWhenTheyAreNoLongerNeededQuery()
  }
}
