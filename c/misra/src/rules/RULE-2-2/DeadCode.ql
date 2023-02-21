/**
 * @id c/misra/dead-code
 * @name RULE-2-2: There shall be no dead code
 * @description Dead code complicates the program and can indicate a possible mistake on the part of
 *              the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-2-2
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.deadcode.DeadCode

class MisraCDeadCodeQuery extends DeadCodeSharedQuery {
  MisraCDeadCodeQuery() { this = DeadCodePackage::deadCodeQuery() }
}
