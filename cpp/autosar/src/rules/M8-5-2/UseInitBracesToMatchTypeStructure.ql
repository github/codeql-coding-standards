/**
 * @id cpp/autosar/use-init-braces-to-match-type-structure
 * @name M8-5-2: Braces shall be used to indicate and match the structure in the non-zero initialization of arrays and structures
 * @description It can be confusing to the developer if the structure of braces in an initializer
 *              does not match the structure of the object being initialized.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/m8-5-2
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.useinitializerbracestomatchaggregatetypestructure.UseInitializerBracesToMatchAggregateTypeStructure

class UseInitBracesToMatchTypeStructureQuery extends UseInitializerBracesToMatchAggregateTypeStructureSharedQuery {
  UseInitBracesToMatchTypeStructureQuery() {
    this = InitializationPackage::useInitBracesToMatchTypeStructureQuery()
  }
}
