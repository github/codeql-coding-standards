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

class Candidate extends TemplateFunction {
  Candidate() {
    this.getAParameter().getType().(RValueReferenceType).getBaseType() instanceof TemplateParameter
  }
}

from Candidate c, Function f, Function overload, Function overloaded, string msg
where
  not isExcluded(f,
    OperatorsPackage::functionThatContainsForwardingReferenceAsItsArgumentOverloadedQuery()) and
  not f.isDeleted() and
  f = c.getAnOverload() and
  // allow for overloading with different number of parameters, because there is no
  // confusion on what function will be called.
  f.getNumberOfParameters() = c.getNumberOfParameters() and
  //build a dynamic select statement that guarantees to read that the overloading function is the explicit one
  if
    (f instanceof CopyConstructor or f instanceof MoveConstructor) and
    f.isCompilerGenerated()
  then (
    msg = "implicit constructor" and
    overloaded = f and
    overload = c
  ) else (
    msg = "function" and
    overloaded = c and
    overload = f
  )
select overload, "Function overloads a $@ with a forwarding reference parameter.", overloaded, msg
