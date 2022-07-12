/**
 * @id cpp/autosar/null-pointer-constant-not-nullptr
 * @name A4-10-1: Only nullptr literal shall be used as the null-pointer-constant
 * @description Using a constant other than nullptr as null-pointer-constant can lead to confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a4-10-1
 *       readability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.commons.NULL

from Literal l
where
  not isExcluded(l, LiteralsPackage::nullPointerConstantNotNullptrQuery()) and
  // Not the type of the nullptr literal
  not l.getType() instanceof NullPointerType and
  // Converted to a pointer type
  l.getConversion().getType().getUnspecifiedType() instanceof PointerType and
  // Value of zero
  l.getValue() = "0" and
  // Not the StringLiteral "0"
  not l instanceof StringLiteral
select l, l.getValueText() + " is used as the null-pointer-constant but is not nullptr."
