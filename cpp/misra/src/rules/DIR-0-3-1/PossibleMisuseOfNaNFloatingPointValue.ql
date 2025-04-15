/**
 * @id cpp/misra/possible-misuse-of-nan-floating-point-value
 * @name DIR-0-3-1: Possible mishandling of an undetected NaN value produced by a floating point operation
 * @description Possible mishandling of an undetected NaN value produced by a floating point
 *              operation.
 * @kind path-problem
 * @precision low
 * @problem.severity warning
 * @tags external/misra/id/dir-0-3-1
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.misuseofnanfloatingpointvalue.MisuseOfNaNFloatingPointValue

class PossibleMisuseOfNaNFloatingPointValueQuery extends MisuseOfNaNFloatingPointValueSharedQuery {
  PossibleMisuseOfNaNFloatingPointValueQuery() {
    this = FloatingPointPackage::possibleMisuseOfNaNFloatingPointValueQuery()
  }
}
