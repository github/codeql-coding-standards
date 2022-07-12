/**
 * @id cpp/autosar/exception-raised-during-termination
 * @name M15-3-1: Exceptions shall be raised only after start-up
 * @description Exceptions raised before start-up or during termination can lead to the program
 *              being terminated in an implementation defined manner.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m15-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph

/**
 * An `ExceptionThrowingFunction` which is called when destroying a non-local variable after termination.
 */
class PostMainThrowingFunction extends ExceptionThrowingFunction {
  GlobalOrNamespaceVariable gv;

  PostMainThrowingFunction() {
    // Any global or namespace variable which is of Class type will have the destructor called on termination
    this = gv.getType().(Class).getDestructor()
  }

  GlobalOrNamespaceVariable getNonLocalVariable() { result = gv }
}

from
  PostMainThrowingFunction postMainThrowingFunction, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode, ExceptionType et, GlobalOrNamespaceVariable nonLocalVariable
where
  not isExcluded(postMainThrowingFunction,
    Exceptions2Package::exceptionRaisedDuringTerminationQuery()) and
  postMainThrowingFunction.hasExceptionFlow(exceptionSource, functionNode, et) and
  nonLocalVariable = postMainThrowingFunction.getNonLocalVariable()
select nonLocalVariable, exceptionSource, functionNode,
  "Variable " + nonLocalVariable.getName() + " can throw an exception of type " +
    et.getExceptionName() + " after termination when calling $@.", postMainThrowingFunction,
  postMainThrowingFunction.getName()
