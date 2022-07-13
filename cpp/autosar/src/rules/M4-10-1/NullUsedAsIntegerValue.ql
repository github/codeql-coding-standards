/**
 * @id cpp/autosar/null-used-as-integer-value
 * @name M4-10-1: NULL shall not be used as an integer value
 * @description Using NULL as an integer literal is potentially confusing.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m4-10-1
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.enhancements.MacroEnhacements

from MacroEnhancements::NULL n
where
  not isExcluded(n, LiteralsPackage::nullUsedAsIntegerValueQuery()) and
  // Not converted to a PointerType
  not n.getConversion().getType().getUnspecifiedType() instanceof PointerType
select n, "NULL macro used as an integer value."
