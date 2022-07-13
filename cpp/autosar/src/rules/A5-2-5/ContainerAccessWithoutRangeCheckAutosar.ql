/**
 * @id cpp/autosar/container-access-without-range-check-autosar
 * @name A5-2-5: A container shall not be accessed beyond its range
 * @description Accessing or writing to a container using an index which is not checked to be within
 *              the bounds of the container can lead reading or writing outside the bounds of the
 *              allocated memory.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a5-2-5
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.containeraccesswithoutrangecheck.ContainerAccessWithoutRangeCheck

class ContainerAccessWithoutRangeCheckAutosarQuery extends ContainerAccessWithoutRangeCheckSharedQuery {
  ContainerAccessWithoutRangeCheckAutosarQuery() {
    this = OutOfBoundsPackage::containerAccessWithoutRangeCheckAutosarQuery()
  }
}
