/**
 * @id cpp/cert/returning-lambda-object-with-capture-by-reference
 * @name EXP61-CPP: Function returning a lambda object that captures objects by reference
 * @description Invoking a lambda object's function call operator on a lambda object with an object
 *              captured by reference that no longer references a valid object results in undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp61-cpp
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.danglingcapturewhenreturninglambdaobject.DanglingCaptureWhenReturningLambdaObject

class ReturnedLambdaObjectOutlivesCaptureByReferenceQuery extends DanglingCaptureWhenReturningLambdaObjectSharedQuery {
  ReturnedLambdaObjectOutlivesCaptureByReferenceQuery() {
    this = LambdasPackage::returningLambdaObjectWithCaptureByReferenceQuery()
  }
}
