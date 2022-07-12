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

from Candidate c, Function f
where
  not isExcluded(f,
    OperatorsPackage::functionThatContainsForwardingReferenceAsItsArgumentOverloadedQuery()) and
  not f.isDeleted() and
  f = c.getAnOverload()
select f, "Function overloads a $@ with a forwarding reference parameter.", c, "function"
