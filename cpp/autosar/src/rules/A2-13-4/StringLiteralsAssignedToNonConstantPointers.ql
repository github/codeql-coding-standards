/**
 * @id cpp/autosar/string-literals-assigned-to-non-constant-pointers
 * @name A2-13-4: String literals shall not be assigned to non-constant pointers
 * @description The type of string literal as of C++0x was changed from 'array of char' to array of
 *              const char and therefore assignment to a non-const pointer is considered an error,
 *              which is reported as a warning by some compliers.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-13-4
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.stringliteralsassignedtononconstantpointersshared.StringLiteralsAssignedToNonConstantPointersShared

module StringLiteralsAssignedToNonConstantPointersConfig implements
  StringLiteralsAssignedToNonConstantPointersSharedConfigSig
{
  Query getQuery() { result = StringsPackage::stringLiteralsAssignedToNonConstantPointersQuery() }
}

import StringLiteralsAssignedToNonConstantPointersShared<StringLiteralsAssignedToNonConstantPointersConfig>
