/**
 * @id cpp/autosar/recursive-functions
 * @name A7-5-2: Functions shall not call themselves, either directly or indirectly
 * @description Using recursive functions can lead to stack overflows and limit scalability and
 *              portability of the program.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-5-2
 *       correctness
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class RecursiveCall extends FunctionCall {
  RecursiveCall() {
    this.getTarget().calls*(this.getEnclosingFunction()) and
    not this.getTarget().hasSpecifier("is_constexpr")
  }
}

from RecursiveCall call, string msg, FunctionCall fc
where
  not isExcluded(fc, FunctionsPackage::recursiveFunctionsQuery()) and
  fc.getTarget() = call.getTarget() and
  if fc.getTarget() = fc.getEnclosingFunction()
  then msg = "This call directly invokes its containing function $@."
  else
    msg =
      "The function " + fc.getEnclosingFunction() + " is indirectly recursive via this call to $@."
select fc, msg, fc.getTarget(), fc.getTarget().getName()
