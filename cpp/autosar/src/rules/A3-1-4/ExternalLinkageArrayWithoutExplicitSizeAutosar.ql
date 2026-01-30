/**
 * @id cpp/autosar/external-linkage-array-without-explicit-size-autosar
 * @name A3-1-4: When an array with external linkage is declared, its size shall be stated explicitly
 * @description A developer can more safely access the elements of an array if the size of the array
 *              can be explicitly determined.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-1-4
 *       correctness
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.externallinkagearraywithoutexplicitsize.ExternalLinkageArrayWithoutExplicitSize

class ExternalLinkageArrayWithoutExplicitSizeAutosarQuery extends ExternalLinkageArrayWithoutExplicitSizeSharedQuery
{
  ExternalLinkageArrayWithoutExplicitSizeAutosarQuery() {
    this = ScopePackage::externalLinkageArrayWithoutExplicitSizeAutosarQuery()
  }
}
