/**
 * @id cpp/autosar/use-of-unsafe-c-string-to-number-conversion
 * @name A18-0-2: Use of unsafe C string to number conversion routine
 * @description Some functions for string-to-number conversions in the C Standard library have
 *              undefined behavior when a string cannot be converted to a number.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a18-0-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class UnsafeStringToNumberAPI extends FunctionCall {
  UnsafeStringToNumberAPI() { getTarget().hasGlobalOrStdName(["atoi", "atol", "atoll", "atof"]) }
}

from UnsafeStringToNumberAPI unsafeStringToNumberAPI
where
  not isExcluded(unsafeStringToNumberAPI,
    TypeRangesPackage::useOfUnsafeCStringToNumberConversionQuery())
select unsafeStringToNumberAPI,
  "Use of string-to-number coversion function '" + unsafeStringToNumberAPI.getTarget().getName() +
    "' which has undefined behavior when converting invalid strings."
