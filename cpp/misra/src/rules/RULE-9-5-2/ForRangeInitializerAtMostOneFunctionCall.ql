/**
 * @id cpp/misra/for-range-initializer-at-most-one-function-call
 * @name RULE-9-5-2: A for-range-initializer shall contain at most one function call
 * @description Multiple function calls in a for-range-initializer can lead to unclear iteration
 *              behavior and potential side effects that make the code harder to understand and
 *              debug.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-5-2
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/allocated-target/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from RangeBasedForStmt foreach, Expr initializer
where
  not isExcluded(foreach, StatementsPackage::forRangeInitializerAtMostOneFunctionCallQuery()) and
  initializer = foreach.getRange() and
  count(Call call | call = initializer.getAChild*() | call) >= 2
select foreach, "Range-based for loop has nested call expression in its $@.", initializer,
  "initializer"
