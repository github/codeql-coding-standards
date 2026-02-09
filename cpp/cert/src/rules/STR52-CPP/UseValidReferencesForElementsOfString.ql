/**
 * @id cpp/cert/use-valid-references-for-elements-of-string
 * @name STR52-CPP: Use valid references, pointers, and iterators to reference elements of a basic_string
 * @description Using references, pointers, and iterators to containers after calling certain
 *              functions can cause unreliable program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/str52-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.validcontainerelementaccess.ValidContainerElementAccess

class UseValidReferencesForElementsOfStringQuery extends ValidContainerElementAccessSharedQuery {
  UseValidReferencesForElementsOfStringQuery() {
    this = IteratorsPackage::useValidReferencesForElementsOfStringQuery()
  }
}
