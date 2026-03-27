/**
 * @id cpp/misra/division-by-zero-undefined-behavior
 * @name RULE-4-1-3: Division or modulo by zero leads to undefined behavior
 * @description Division or remainder by zero results in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.divisorequaltozeroshared.DivisorEqualToZeroShared

module DivisionByZeroUndefinedBehaviorConfig implements DivisorEqualToZeroSharedConfigSig {
  Query getQuery() { result = UndefinedPackage::divisionByZeroUndefinedBehaviorQuery() }
}

import DivisorEqualToZeroShared<DivisionByZeroUndefinedBehaviorConfig>
