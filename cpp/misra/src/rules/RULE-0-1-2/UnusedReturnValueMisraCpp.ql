/**
 * @id cpp/misra/unused-return-value-misra-cpp
 * @name RULE-0-1-2: The value returned by a function shall be used
 * @description The result of a non-void function shall be used if called with function call syntax.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-0-1-2
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.unusedreturnvalue.UnusedReturnValue

module UnusedReturnValueMisraCppConfig implements UnusedReturnValueConfigSig {
  Query getQuery() { result = DeadCode6Package::unusedReturnValueMisraCppQuery() }
}

import UnusedReturnValue<UnusedReturnValueMisraCppConfig>
