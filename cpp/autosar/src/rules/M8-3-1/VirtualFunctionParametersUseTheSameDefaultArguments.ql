/**
 * @id cpp/autosar/virtual-function-parameters-use-the-same-default-arguments
 * @name M8-3-1: Parameters in an overriding virtual function shall have the same default arguments or no default arguments
 * @description Parameters in an overriding virtual function shall either use the same default
 *              arguments as the function they override, or else shall not specify any default
 *              arguments.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m8-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from VirtualFunction f1, VirtualFunction f2
where
  not isExcluded(f1,
    VirtualFunctionsPackage::virtualFunctionParametersUseTheSameDefaultArgumentsQuery()) and
  not isExcluded(f2,
    VirtualFunctionsPackage::virtualFunctionParametersUseTheSameDefaultArgumentsQuery()) and
  f2 = f1.getAnOverridingFunction() and
  exists(Parameter p1, Parameter p2 |
    p1 = f1.getAParameter() and
    p2 = f2.getParameter(p1.getIndex())
  |
    if p1.hasInitializer()
    then
      // if there is no initializer
      not p2.hasInitializer()
      or
      // if there is one and it doesn't match
      not p1.getInitializer().getExpr().getValueText() =
        p2.getInitializer().getExpr().getValueText()
    else
      // if p1 doesn't have an initializer p2 shouldn't either
      p2.hasInitializer()
  )
select f2, "$@ does not have the same default parameters as $@", f2, "overriding function", f1,
  "overridden function"
