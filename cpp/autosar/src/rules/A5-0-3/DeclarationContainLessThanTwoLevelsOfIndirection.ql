/**
 * @id cpp/autosar/declaration-contain-less-than-two-levels-of-indirection
 * @name A5-0-3: The declaration of objects shall contain no more than two levels of pointer indirection
 * @description The declaration of objects shall contain no more than two levels of pointer
 *              indirection, because the use or more than two levels can impair the ability to
 *              understand the behavior of the code.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a5-0-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.donotusemorethantwolevelsofpointerindirection.DoNotUseMoreThanTwoLevelsOfPointerIndirection

class DeclarationContainLessThanTwoLevelsOfIndirectionQuery extends DoNotUseMoreThanTwoLevelsOfPointerIndirectionSharedQuery {
  DeclarationContainLessThanTwoLevelsOfIndirectionQuery() {
    this = PointersPackage::declarationContainLessThanTwoLevelsOfIndirectionQuery()
  }
}
