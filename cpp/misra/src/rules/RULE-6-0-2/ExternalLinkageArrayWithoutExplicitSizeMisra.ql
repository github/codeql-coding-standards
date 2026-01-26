/**
 * @id cpp/misra/external-linkage-array-without-explicit-size-misra
 * @name RULE-6-0-2: Arrays with external linkage declared without explicit size shall not be used
 * @description Declaring an array with external linkage without its size being explicitly specified
 *              can disallow consistency and range checks on the array size and usage.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-6-0-2
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.externallinkagearraywithoutexplicitsize.ExternalLinkageArrayWithoutExplicitSize

class ExternalLinkageArrayWithoutExplicitSizeMisraQuery extends ExternalLinkageArrayWithoutExplicitSizeSharedQuery
{
  ExternalLinkageArrayWithoutExplicitSizeMisraQuery() {
    this = Linkage1Package::externalLinkageArrayWithoutExplicitSizeMisraQuery()
  }
}
