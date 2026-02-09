/**
 * @id c/misra/possible-misuse-of-undetected-nan
 * @name DIR-4-15: Evaluation of floating-point expressions shall not lead to the undetected generation of NaNs
 * @description Evaluation of floating-point expressions shall not lead to the undetected generation
 *              of NaNs.
 * @kind path-problem
 * @precision low
 * @problem.severity warning
 * @tags external/misra/id/dir-4-15
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.misuseofnanfloatingpointvalue.MisuseOfNaNFloatingPointValue

class PossibleMisuseOfUndetectedNaNQuery extends MisuseOfNaNFloatingPointValueSharedQuery {
  PossibleMisuseOfUndetectedNaNQuery() {
    this = FloatingTypes2Package::possibleMisuseOfUndetectedNaNQuery()
  }
}
