/**
 * @id cpp/cert/uses-valid-container-element-access
 * @name CTR51-CPP: Use valid references, pointers, and iterators to reference elements of a container
 * @description Using references, pointers, and iterators to containers after calling certain
 *              functions can cause unreliable program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/ctr51-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.validcontainerelementaccess.ValidContainerElementAccess

class UsesValidContainerElementAccessQuery extends ValidContainerElementAccessSharedQuery {
  UsesValidContainerElementAccessQuery() {
    this = IteratorsPackage::usesValidContainerElementAccessQuery()
  }
}
