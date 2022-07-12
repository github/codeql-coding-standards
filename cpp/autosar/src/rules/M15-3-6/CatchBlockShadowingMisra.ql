/**
 * @id cpp/autosar/catch-block-shadowing-misra
 * @name M15-3-6: Catch block is shadow by prior catch block
 * @description Where multiple handlers are provided in a single try-catch statement or
 *              function-try-block for a derived class and some or all of its bases, the handlers
 *              shall be ordered most-derived to base class.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m15-3-6
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.catchblockshadowing.CatchBlockShadowing

class CatchBlockShadowingMisraQuery extends CatchBlockShadowingSharedQuery {
  CatchBlockShadowingMisraQuery() { this = Exceptions2Package::catchBlockShadowingMisraQuery() }
}
