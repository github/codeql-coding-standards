/**
 * @id cpp/autosar/variable-width-integer-types-used
 * @name A3-9-1: Use fixed-width integer types instead of basic, variable-width, integer types
 * @description The basic numerical types of char, int, short, long are not supposed to be used. The
 *              specific-length types from <cstdint> header need be used instead.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a3-9-1
 *       correctness
 *       security
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.EncapsulatingFunctions

/**
 * any `Parameter` in a main function like:
 * int main(int argc, char *argv[])
 */
class ExcludedVariable extends Parameter {
  ExcludedVariable() { getFunction() instanceof MainFunction }
}

from Variable v
where
  not isExcluded(v, DeclarationsPackage::variableWidthIntegerTypesUsedQuery()) and
  (
    v.getType() instanceof PlainCharType
    or
    v.getType() instanceof UnsignedCharType
    or
    v.getType() instanceof SignedCharType
    or
    v.getType() instanceof ShortType
    or
    v.getType() instanceof IntType
    or
    v.getType() instanceof LongType
    or
    v.getType() instanceof LongLongType
  ) and
  not v instanceof ExcludedVariable
select v, "Variable '" + v.getName() + "' has variable-width type."
