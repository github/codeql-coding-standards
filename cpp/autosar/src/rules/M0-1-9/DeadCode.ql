/**
 * @id cpp/autosar/dead-code
 * @name M0-1-9: There shall be no dead code
 * @description Dead code complicates the program and can indicate a possible mistake on the part of
 *              the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m0-1-9
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.deadcode.DeadCode

class MisraCppDeadCodeQuery extends DeadCodeSharedQuery {
  MisraCppDeadCodeQuery() { this = DeadCodePackage::deadCodeQuery() }
}
