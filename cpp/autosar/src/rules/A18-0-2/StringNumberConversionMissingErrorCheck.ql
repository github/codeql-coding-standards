/**
 * @id cpp/autosar/string-number-conversion-missing-error-check
 * @name A18-0-2: The error state of a conversion from string to a numeric value shall be checked
 * @description A string-to-number conversion may fail if the input string is not a number or is out
 *              of range, which may lead to inconsistent program behavior if not caught.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a18-0-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.stringnumberconversionmissingerrorcheck.StringNumberConversionMissingErrorCheck

class StringNumberConversionMissingErrorCheckQuery extends StringNumberConversionMissingErrorCheckSharedQuery {
  StringNumberConversionMissingErrorCheckQuery() {
    this = TypeRangesPackage::stringNumberConversionMissingErrorCheckQuery()
  }
}
