/**
 * @id cpp/autosar/union-keyword-used-autosar-cpp
 * @name A9-5-1: Unions shall not be used
 * @description Unions shall not be used. Tagged unions can be used if 'std::variant' is not
 *              available.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a9-5-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.unionkeywordused.UnionKeywordUsed

module UnionKeywordUsedAutosarCppConfig implements UnionKeywordUsedConfigSig {
  Query getQuery() { result = BannedSyntaxPackage::unionKeywordUsedAutosarCppQuery() }
}

import UnionKeywordUsed<UnionKeywordUsedAutosarCppConfig>
