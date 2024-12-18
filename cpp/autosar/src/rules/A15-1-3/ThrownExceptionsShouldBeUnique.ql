/**
 * @id cpp/autosar/thrown-exceptions-should-be-unique
 * @name A15-1-3: All thrown exceptions should be unique
 * @description Throwing unique exceptions make it easier to trace the source code location of
 *              exceptions observed at runtime.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a15-1-3
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionFlow
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.HashCons

/** Find a value which defines the exception thrown by the `DirectThrowExpr`, if any. */
private Expr getADefiningValue(DirectThrowExpr dte) {
  DataFlow::localExprFlow(result, dte.getExpr()) and
  (
    result instanceof Literal
    or
    result instanceof Call
  )
}

predicate matchingExceptions(
  DirectThrowExpr throwOne, DirectThrowExpr throwTwo, Expr exceptionDefOne, Expr exceptionDefTwo
) {
  throwOne.getExceptionType() = throwTwo.getExceptionType() and
  not throwOne = throwTwo and
  exceptionDefOne = getADefiningValue(throwOne) and
  exceptionDefTwo = getADefiningValue(throwTwo) and
  (
    // Structural equality
    hashCons(exceptionDefOne) = hashCons(exceptionDefTwo)
    or
    // Evaluates to the same constant expression
    exceptionDefOne.getValue() = exceptionDefTwo.getValue()
  )
}

from DirectThrowExpr throwOne, DirectThrowExpr throwTwo, Expr exceptionDefOne, Expr exceptionDefTwo
where
  not isExcluded(throwOne, Exceptions1Package::thrownExceptionsShouldBeUniqueQuery()) and
  not isExcluded(throwTwo, Exceptions1Package::thrownExceptionsShouldBeUniqueQuery()) and
  matchingExceptions(throwOne, throwTwo, exceptionDefOne, exceptionDefTwo)
select throwOne, "The $@ thrown here is a possible duplicate of the $@ thrown $@.", exceptionDefOne,
  throwOne.getExceptionType().(ExceptionType).getExceptionName() + " exception", exceptionDefTwo,
  "exception", throwTwo, "here"
