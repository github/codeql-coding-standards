/**
 * @id cpp/autosar/variable-width-plain-char-type-used
 * @name A3-9-1: Use a fixed-width integer type instead of a char type
 * @description The basic numerical type char is not supposed to be used. The specific-length types
 *              from <cstdint> header need be used instead.
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
import codingstandards.cpp.Type

from Variable variable
where
  not isExcluded(variable, DeclarationsPackage::variableWidthPlainCharTypeUsedQuery()) and
  stripSpecifiers(variable.getType()) instanceof PlainCharType
select variable, "Variable '" + variable.getName() + "' has variable-width char type."
