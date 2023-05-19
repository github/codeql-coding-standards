/**
 * @id cpp/cert/catch-exceptions-by-lvalue-reference
 * @name ERR61-CPP: Catch exceptions by lvalue reference
 * @description A non-trivial exception which is not caught by lvalue reference may be sliced,
 *              losing valuable exception information.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/err61-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.catchexceptionsbylvaluereference.CatchExceptionsByLvalueReference

class CatchExceptionsByLvalueReferenceQuery extends CatchExceptionsByLvalueReferenceSharedQuery {
  CatchExceptionsByLvalueReferenceQuery() {
    this = Exceptions1Package::catchExceptionsByLvalueReferenceQuery()
  }
}
