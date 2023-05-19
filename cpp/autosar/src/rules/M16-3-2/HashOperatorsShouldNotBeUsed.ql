/**
 * @id cpp/autosar/hash-operators-should-not-be-used
 * @name M16-3-2: The # and ## operators should not be used
 * @description The order of evaluation for the '#' and '##' operators may differ between compilers,
 *              which can cause unexpected behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-3-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.hashoperatorsused.HashOperatorsUsed

class HashOperatorsShallNotBeUsedInQuery extends HashOperatorsUsedSharedQuery {
  HashOperatorsShallNotBeUsedInQuery() { this = MacrosPackage::hashOperatorsShouldNotBeUsedQuery() }
}
