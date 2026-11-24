/**
 * @id c/misra/reserved-identifier-declared
 * @name RULE-5-10: A reserved identifier or reserved macro name shall not be declared
 * @description Declaring a reserved identifier can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-10
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/c/2025
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.declaredareservedidentifier.DeclaredAReservedIdentifier

/** A query that reports reserved identifier declarations for MISRA C:2025 Rule 5.10. */
class ReservedIdentifierDeclaredQuery extends DeclaredAReservedIdentifierSharedQuery {
  ReservedIdentifierDeclaredQuery() {
    this = Declarations1Package::reservedIdentifierDeclaredQuery()
  }
}
