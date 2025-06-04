/**
 * @id cpp/cert/escaping-lambda-object-with-capture-by-reference
 * @name EXP61-CPP: Storing lambda object capturing an object by reference in a member or global variable
 * @description Invoking a lambda object's function call operator on a lambda object with an object
 *              captured by reference that no longer references a valid object results in undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp61-cpp
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.danglingcapturewhenmovinglambdaobject.DanglingCaptureWhenMovingLambdaObject

class MovedLambdaObjectOutlivesCaptureByReferenceQuery extends DanglingCaptureWhenMovingLambdaObjectSharedQuery
{
  MovedLambdaObjectOutlivesCaptureByReferenceQuery() {
    this = LambdasPackage::escapingLambdaObjectWithCaptureByReferenceQuery()
  }
}
