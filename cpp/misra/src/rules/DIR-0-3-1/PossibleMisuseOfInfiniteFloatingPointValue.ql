/**
 * @id cpp/misra/possible-misuse-of-infinite-floating-point-value
 * @name DIR-0-3-1: Possible misuse of a generate infinite floating point value
 * @description Possible misuse of a generate infinite floating point value.
 * @kind path-problem
 * @precision medium
 * @problem.severity warning
 * @tags external/misra/id/dir-0-3-1
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.misuseofinfinitefloatingpointvalue.MisuseOfInfiniteFloatingPointValue

class PossibleMisuseOfInfiniteFloatingPointValueQuery extends MisuseOfInfiniteFloatingPointValueSharedQuery
{
  PossibleMisuseOfInfiniteFloatingPointValueQuery() {
    this = FloatingPointPackage::possibleMisuseOfInfiniteFloatingPointValueQuery()
  }
}
