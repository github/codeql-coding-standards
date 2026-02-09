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
import codingstandards.cpp.rules.variablewidthintegertypesused.VariableWidthIntegerTypesUsed

class VariableWidthIntegerTypesUsedQuery extends VariableWidthIntegerTypesUsedSharedQuery {
  VariableWidthIntegerTypesUsedQuery() {
    this = DeclarationsPackage::variableWidthIntegerTypesUsedQuery()
  }
}
