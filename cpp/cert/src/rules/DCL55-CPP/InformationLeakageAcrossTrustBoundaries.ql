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
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.trustboundary.UninitializedField

from Element e, string alertMessage
where
  not isExcluded(e, UninitializedPackage::informationLeakageAcrossTrustBoundariesQuery()) and
  uninitializedFieldQuery(e, alertMessage)
select e, alertMessage
