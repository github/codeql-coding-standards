/**
 * @id c/misra/file-used-after-closed
 * @name RULE-22-6: The value of a pointer to a FILE shall not be used after the associated stream has been closed
 * @description A closed FILE is accessed.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-6
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.donotaccessaclosedfile.DoNotAccessAClosedFile

class FileUsedAfterClosedQuery extends DoNotAccessAClosedFileSharedQuery {
  FileUsedAfterClosedQuery() { this = IO1Package::fileUsedAfterClosedQuery() }
}
