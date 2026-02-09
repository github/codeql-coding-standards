/**
 * @id cpp/cert/operation-may-not-null-terminate-c-style-string-cert
 * @name STR50-CPP: A C-style string shall guarantee sufficient space for data and the null terminator
 * @description Certain operations may not null terminate CStyle strings which may cause
 *              unpredictable behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/cert/id/str50-cpp
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.operationmaynotnullterminatecstylestring.OperationMayNotNullTerminateCStyleString

class OperationMayNotNullTerminateCStyleStringCertQuery extends OperationMayNotNullTerminateCStyleStringSharedQuery
{
  OperationMayNotNullTerminateCStyleStringCertQuery() {
    this = StringsPackage::operationMayNotNullTerminateCStyleStringCertQuery()
  }
}
