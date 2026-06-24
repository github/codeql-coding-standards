/**
 * @id c/cert/signed-integer-overflow
 * @name INT32-C: Ensure that operations on signed integers do not result in overflow
 * @description The multiplication of two signed integers can lead to underflow or overflow and
 *              therefore undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/int32-c
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
import codingstandards.c.cert
import codingstandards.cpp.rules.signedintegeroverflowshared.SignedIntegerOverflowShared

module SignedIntegerOverflowConfig implements SignedIntegerOverflowSharedConfigSig {
  Query getQuery() { result = IntegerOverflowPackage::signedIntegerOverflowQuery() }
}

import SignedIntegerOverflowShared<SignedIntegerOverflowConfig>
