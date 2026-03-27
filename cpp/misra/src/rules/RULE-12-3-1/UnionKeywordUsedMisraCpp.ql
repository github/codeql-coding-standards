/**
 * @id cpp/misra/union-keyword-used-misra-cpp
 * @name RULE-12-3-1: The union keyword shall not be used
 * @description Using unions should be avoided and 'std::variant' should be used as a type-safe
 *              alternative.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-3-1
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.unionkeywordused.UnionKeywordUsed

module UnionKeywordUsedMisraCppConfig implements UnionKeywordUsedConfigSig {
  Query getQuery() { result = Banned6Package::unionKeywordUsedMisraCppQuery() }
}

import UnionKeywordUsed<UnionKeywordUsedMisraCppConfig>
