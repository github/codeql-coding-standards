/**
 * @id cpp/autosar/valid-container-element-access
 * @name A23-0-2: Elements of a container shall only be accessed via valid references, iterators, and pointers
 * @description Using references, pointers, and iterators to containers after calling certain
 *              functions can cause unreliable program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a23-0-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.validcontainerelementaccess.ValidContainerElementAccess

class ValidContainerElementAccessQuery extends ValidContainerElementAccessSharedQuery {
  ValidContainerElementAccessQuery() { this = IteratorsPackage::validContainerElementAccessQuery() }
}
