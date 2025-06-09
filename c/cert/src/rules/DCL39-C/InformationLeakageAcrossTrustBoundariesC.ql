/**
 * @id c/cert/information-leakage-across-trust-boundaries-c
 * @name DCL39-C: Avoid information leakage when passing a structure across a trust boundary
 * @description Passing a structure with uninitialized fields or padding bytes can cause information
 *              to be unintentionally leaked.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/dcl39-c
 *       security
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p1
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.informationleakageacrossboundaries.InformationLeakageAcrossBoundaries

class InformationLeakageAcrossTrustBoundariesCQuery extends InformationLeakageAcrossBoundariesSharedQuery
{
  InformationLeakageAcrossTrustBoundariesCQuery() {
    this = Declarations7Package::informationLeakageAcrossTrustBoundariesCQuery()
  }
}
