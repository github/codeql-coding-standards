/**
 * @id cpp/autosar/unreachable-code
 * @name M0-1-1: A project shall not contain unreachable code
 * @description Unreachable code complicates the program and can indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m0-1-1
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.deadcode.UnreachableCode
import codingstandards.cpp.rules.unreachablecode.UnreachableCode

class UnreachableCodeQuery extends UnreachableCodeSharedQuery {
  UnreachableCodeQuery() { this = DeadCodePackage::unreachableCodeQuery() }
}
