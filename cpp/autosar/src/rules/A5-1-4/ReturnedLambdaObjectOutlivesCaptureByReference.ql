/**
 * @id cpp/autosar/returned-lambda-object-outlives-capture-by-reference
 * @name A5-1-4: Function returning a lambda object that captures objects by reference
 * @description Invoking a lambda object's function call operator on a lambda object with an object
 *              captured by reference that no longer references a valid object results in undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a5-1-4
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.danglingcapturewhenreturninglambdaobject.DanglingCaptureWhenReturningLambdaObject

class ReturnedLambdaObjectOutlivesCaptureByReferenceQuery extends DanglingCaptureWhenReturningLambdaObjectSharedQuery {
  ReturnedLambdaObjectOutlivesCaptureByReferenceQuery() {
    this = LambdasPackage::returnedLambdaObjectOutlivesCaptureByReferenceQuery()
  }
}
