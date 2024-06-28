/**
 * @id cpp/autosar/explicit-specializations-of-function-templates-used
 * @name A14-8-2: Explicit specializations of function templates shall not be used
 * @description Using function template specialization in combination with function overloading
 *              makes call target resolution more difficult to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a14-8-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.functiontemplatesexplicitlyspecialized_shared.FunctionTemplatesExplicitlySpecialized_shared

class ExplicitSpecializationsOfFunctionTemplatesUsedQuery extends FunctionTemplatesExplicitlySpecialized_sharedSharedQuery
{
  ExplicitSpecializationsOfFunctionTemplatesUsedQuery() {
    this = TemplatesPackage::explicitSpecializationsOfFunctionTemplatesUsedQuery()
  }
}
