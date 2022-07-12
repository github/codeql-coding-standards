/**
 * @id cpp/autosar/literal-zero-used-as-null-pointer-constant
 * @name M4-10-2: Literal zero (0) shall not be used as the null-pointer-constant
 * @description Using literal zero (0) as the null-pointer-constant is potentially confusiing.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m4-10-2
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.enhancements.MacroEnhacements

from Literal l
where
  not isExcluded(l, LiteralsPackage::literalZeroUsedAsNullPointerConstantQuery()) and
  // Converted to a pointer type
  l.getConversion().getType().getUnspecifiedType() instanceof PointerType and
  // Literal 0
  l.getValueText() = "0" and
  // And not of nullptr type -
  not l.getType() instanceof NullPointerType and
  // Exclude the 0 literal generated from the NULL macro, which is permitted by this rule.
  not l instanceof MacroEnhancements::NULL
select l, "Literal 0 used as the null-pointer-constant."
