/**
 * @id cpp/cert/information-leakage-across-trust-boundaries
 * @name DCL55-CPP: Avoid information leakage when passing a class object across a trust boundary
 * @description Passing a class object with uninitialized data or padding bytes can cause
 *              information to be unintentionally leaked.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/dcl55-cpp
 *       security
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p1
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.informationleakageacrossboundaries.InformationLeakageAcrossBoundaries

class InformationLeakageAcrossTrustBoundariesQuery extends InformationLeakageAcrossBoundariesSharedQuery
{
  InformationLeakageAcrossTrustBoundariesQuery() {
    this = UninitializedPackage::informationLeakageAcrossTrustBoundariesQuery()
  }
}
