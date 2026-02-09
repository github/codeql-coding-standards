/**
 * @id cpp/cert/detect-errors-when-converting-a-string-to-a-number
 * @name ERR62-CPP: Detect errors when converting a string to a number
 * @description A string-to-number conversion may fail if the input string is not a number or is out
 *              of range, which may lead to inconsistent program behavior if not caught.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err62-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.stringnumberconversionmissingerrorcheck.StringNumberConversionMissingErrorCheck

class DetectErrorsWhenConvertingAStringToANumberQuery extends StringNumberConversionMissingErrorCheckSharedQuery
{
  DetectErrorsWhenConvertingAStringToANumberQuery() {
    this = TypeRangesPackage::detectErrorsWhenConvertingAStringToANumberQuery()
  }
}
