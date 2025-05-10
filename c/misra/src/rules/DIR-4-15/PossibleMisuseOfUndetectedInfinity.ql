/**
 * @id c/misra/possible-misuse-of-undetected-infinity
 * @name DIR-4-15: Evaluation of floating-point expressions shall not lead to the undetected generation of infinities
 * @description Evaluation of floating-point expressions shall not lead to the undetected generation
 *              of infinities.
 * @kind path-problem
 * @precision medium
 * @problem.severity warning
 * @tags external/misra/id/dir-4-15
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.misuseofinfinitefloatingpointvalue.MisuseOfInfiniteFloatingPointValue

class PossibleMisuseOfUndetectedInfinityQuery extends MisuseOfInfiniteFloatingPointValueSharedQuery {
  PossibleMisuseOfUndetectedInfinityQuery() {
    this = FloatingTypes2Package::possibleMisuseOfUndetectedInfinityQuery()
  }
}
