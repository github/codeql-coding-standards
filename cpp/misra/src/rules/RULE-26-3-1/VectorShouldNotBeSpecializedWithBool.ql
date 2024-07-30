/**
 * @id cpp/misra/vector-should-not-be-specialized-with-bool
 * @name RULE-26-3-1: std::vector should not be specialized with bool
 * @description std::vector should not be specialized with bool.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-26-3-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.vectorshouldnotbespecializedwithbool.VectorShouldNotBeSpecializedWithBool

class VectorShouldNotBeSpecializedWithBoolQuery extends VectorShouldNotBeSpecializedWithBoolSharedQuery
{
  VectorShouldNotBeSpecializedWithBoolQuery() {
    this = ImportMisra23Package::vectorShouldNotBeSpecializedWithBoolQuery()
  }
}
