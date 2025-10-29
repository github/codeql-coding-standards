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
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.overridingshallspecifydifferentdefaultarguments.OverridingShallSpecifyDifferentDefaultArguments

class VirtualFunctionParametersUseTheSameDefaultArgumentsQuery extends OverridingShallSpecifyDifferentDefaultArgumentsSharedQuery
{
  VirtualFunctionParametersUseTheSameDefaultArgumentsQuery() {
    this = VirtualFunctionsPackage::virtualFunctionParametersUseTheSameDefaultArgumentsQuery()
  }
}
