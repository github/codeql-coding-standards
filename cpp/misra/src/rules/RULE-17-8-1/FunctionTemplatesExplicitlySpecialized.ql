/**
 * @id cpp/misra/function-templates-explicitly-specialized
 * @name RULE-17-8-1: Function templates shall not be explicitly specialized
 * @description Function templates shall not be explicitly specialized.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-8-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.functiontemplatesexplicitlyspecialized_shared.FunctionTemplatesExplicitlySpecialized_shared

class FunctionTemplatesExplicitlySpecializedQuery extends FunctionTemplatesExplicitlySpecialized_sharedSharedQuery
{
  FunctionTemplatesExplicitlySpecializedQuery() {
    this = ImportMisra23Package::functionTemplatesExplicitlySpecializedQuery()
  }
}
