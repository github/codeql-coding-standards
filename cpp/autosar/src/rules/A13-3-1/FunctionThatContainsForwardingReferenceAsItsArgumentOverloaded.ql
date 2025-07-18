/**
 * @id cpp/autosar/function-that-contains-forwarding-reference-as-its-argument-overloaded
 * @name A13-3-1: A function that contains 'forwarding reference' as its argument shall not be overloaded
 * @description A function that contains 'forwarding reference' as its argument shall not be
 *              overloaded.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a13-3-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.FunctionEquivalence

class Candidate extends TemplateFunction {
  Candidate() {
    this.getAParameter().getType().(RValueReferenceType).getBaseType() instanceof
      TypeTemplateParameter
  }
}

from
  Candidate c, Function f, Function overload, Function overloaded, string msg,
  string firstMsgSegment
where
  not isExcluded(f,
    OperatorsPackage::functionThatContainsForwardingReferenceAsItsArgumentOverloadedQuery()) and
  not f.isDeleted() and
  f = c.getAnOverload() and
  // Ensure the functions are not equivalent to each other (refer #796).
  not f = getAnEquivalentFunction(c) and
  // allow for overloading with different number of parameters, because there is no
  // confusion on what function will be called.
  f.getNumberOfParameters() = c.getNumberOfParameters() and
  //ignore implicit copy and move constructor overloads
  not (
    f.isCompilerGenerated() and
    (f instanceof CopyConstructor or f instanceof MoveConstructor)
  ) and
  msg = "function with a forwarding reference parameter" and
  firstMsgSegment = " " and
  overloaded = c and
  overload = f
select overload, "Function" + firstMsgSegment + "overloads a $@.", overloaded, msg
