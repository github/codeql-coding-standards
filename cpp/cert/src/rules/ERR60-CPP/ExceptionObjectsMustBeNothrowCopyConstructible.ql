/**
 * @id cpp/cert/exception-objects-must-be-nothrow-copy-constructible
 * @name ERR60-CPP: Exception objects must be nothrow copy constructible
 * @description Exceptions are handled by copy constructing the exception object. If the copy
 *              construction process throws an exception, the application will abruptly terminate.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/err60-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.ExceptionSpecifications

from DirectThrowExpr te, ExceptionType et, CopyConstructor copyConstructor
where
  not isExcluded(te, Exceptions1Package::exceptionObjectsMustBeNothrowCopyConstructibleQuery()) and
  et = te.getExceptionType() and
  copyConstructor.getDeclaringType() = et and
  // Not marked noexcept
  not isNoExceptTrue(copyConstructor) and
  // Not marked deleted
  not copyConstructor.isDeleted()
select te, "Throw calls the copy-constructor $@ which is not marked or inferred as noexcept(true).",
  copyConstructor, copyConstructor.getQualifiedName()
