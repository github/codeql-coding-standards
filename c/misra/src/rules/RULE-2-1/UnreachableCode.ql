/**
 * @id c/misra/unreachable-code
 * @name RULE-2-1: A project shall not contain unreachable code
 * @description Unreachable code complicates the program and can indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-2-1
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.unreachablecode.UnreachableCode

class UnreachableCodeQuery extends UnreachableCodeSharedQuery {
  UnreachableCodeQuery() {
    this = DeadCodePackage::unreachableCodeQuery()
  }
}
