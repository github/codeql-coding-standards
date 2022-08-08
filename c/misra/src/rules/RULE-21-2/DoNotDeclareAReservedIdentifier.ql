/**
 * @id c/misra/do-not-declare-a-reserved-identifier
 * @name RULE-21-2: A reserved identifier or reserved macro name shall not be declared
 * @description Declaring a reserved identifier can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-2
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.declaredareservedidentifier.DeclaredAReservedIdentifier

class DoNotDeclareAReservedIdentifierQuery extends DeclaredAReservedIdentifierSharedQuery {
  DoNotDeclareAReservedIdentifierQuery() {
    this = Declarations1Package::doNotDeclareAReservedIdentifierQuery()
  }
}
