/**
 * @id c/cert/undefined-behavior-accessing-a-closed-file
 * @name FIO46-C: Do not access a closed file
 * @description Do not access a closed file.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio46-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.donotaccessaclosedfile.DoNotAccessAClosedFile

class UndefinedBehaviorAccessingAClosedFileQuery extends DoNotAccessAClosedFileSharedQuery {
  UndefinedBehaviorAccessingAClosedFileQuery() {
    this = IO1Package::undefinedBehaviorAccessingAClosedFileQuery()
  }
}
