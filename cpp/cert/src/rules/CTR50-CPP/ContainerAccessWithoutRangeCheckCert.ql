/**
 * @id cpp/cert/container-access-without-range-check-cert
 * @name CTR50-CPP: A container shall not be accessed beyond its range
 * @description Accessing or writing to a container using an index which is not checked to be within
 *              the bounds of the container can lead reading or writing outside the bounds of the
 *              allocated memory.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/ctr50-cpp
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.containeraccesswithoutrangecheck.ContainerAccessWithoutRangeCheck

class ContainerAccessWithoutRangeCheckCertQuery extends ContainerAccessWithoutRangeCheckSharedQuery {
  ContainerAccessWithoutRangeCheckCertQuery() {
    this = OutOfBoundsPackage::containerAccessWithoutRangeCheckCertQuery()
  }
}
