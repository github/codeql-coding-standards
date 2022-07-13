/**
 * @id cpp/autosar/explicit-abrupt-termination-autosar
 * @name A15-5-2: Do not explicitly abruptly terminate the program
 * @description Abruptly terminating the program can leave resources such as streams and temporary
 *              files in an unclosed state.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a15-5-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.explicitabrupttermination.ExplicitAbruptTermination

class ExplicitAbruptTerminationAutosarQuery extends ExplicitAbruptTerminationSharedQuery {
  ExplicitAbruptTerminationAutosarQuery() {
    this = Exceptions1Package::explicitAbruptTerminationAutosarQuery()
  }
}
