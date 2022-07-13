/**
 * @id cpp/autosar/only-throw-std-exception-derived-types
 * @name A15-1-1: Only instances of types derived from std::exception should be thrown
 * @description Throwing types which are not derived from std::exception can lead to developer
 *              confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a15-1-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.standardlibrary.Exceptions
import codingstandards.cpp.exceptions.ExceptionFlow

from DirectThrowExpr te, ExceptionType et
where
  not isExcluded(te, Exceptions2Package::onlyThrowStdExceptionDerivedTypesQuery()) and
  et = te.getExceptionType() and
  not et.(Class).getABaseClass*() instanceof StdException
select te, "Exception thrown of type $@ which is not derived from std::exception.", et,
  et.getExceptionName()
