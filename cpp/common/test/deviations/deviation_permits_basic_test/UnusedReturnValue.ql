/**
 * @id cpp/autosar/unused-return-value
 * @name A0-1-2: Unused return value
 * @description The value returned by a function having a non-void return type that is not an
 *              overloaded operator shall be used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-2
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.CodingStandards
import codingstandards.cpp.exclusions.cpp.RuleMetadata
import codingstandards.cpp.rules.unusedreturnvalueshared.UnusedReturnValueShared

/* This is a copy of an AUTOSAR rule, which we are using for testing purposes. */
module UnusedReturnValueConfig implements UnusedReturnValueSharedConfigSig {
  Query getQuery() { result = DeadCodePackage::unusedReturnValueQuery() }
}

import UnusedReturnValueShared<UnusedReturnValueConfig>
