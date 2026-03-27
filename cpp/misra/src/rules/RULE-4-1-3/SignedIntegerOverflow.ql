/**
 * @id cpp/misra/signed-integer-overflow
 * @name RULE-4-1-3: Signed integer overflow leads to critical unspecified behavior
 * @description Signed integer overflow or underflow from arithmetic operations results in critical
 *              unspecified behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.signedintegeroverflowshared.SignedIntegerOverflowShared

module SignedIntegerOverflowConfig implements SignedIntegerOverflowSharedConfigSig {
  Query getQuery() { result = UndefinedPackage::signedIntegerOverflowQuery() }
}

import SignedIntegerOverflowShared<SignedIntegerOverflowConfig>
