/**
 * @id cpp/autosar/variable-width-integer-types-used
 * @name A3-9-1: Use fixed-width integer types instead of basic, variable-width, integer types
 * @description The basic numerical types of signed/unsigned char, int, short, long are not supposed
 *              to be used. The specific-length types from <cstdint> header need be used instead.
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
import codingstandards.cpp.BuiltInNumericTypes
import codingstandards.cpp.Type


from Variable v, Type typeStrippedOfSpecifiers
where
  not isExcluded(v, DeclarationsPackage::variableWidthIntegerTypesUsedQuery()) and
  typeStrippedOfSpecifiers = stripSpecifiers(v.getType()) and
  (
    typeStrippedOfSpecifiers instanceof BuiltInIntegerType or
    typeStrippedOfSpecifiers instanceof UnsignedCharType or
    typeStrippedOfSpecifiers instanceof SignedCharType
  ) and
  not v instanceof ExcludedVariable
select v, "Variable '" + v.getName() + "' has variable-width type."
