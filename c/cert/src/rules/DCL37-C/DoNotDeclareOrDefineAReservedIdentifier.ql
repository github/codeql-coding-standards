/**
 * @id c/cert/do-not-declare-or-define-a-reserved-identifier
 * @name DCL37-C: Do not declare or define a reserved identifier
 * @description Declaring a reserved identifier can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/dcl37-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.declaredareservedidentifier.DeclaredAReservedIdentifier

class DoNotDeclareAReservedIdentifierQuery extends DeclaredAReservedIdentifierSharedQuery {
  DoNotDeclareAReservedIdentifierQuery() {
    this = Declarations1Package::doNotDeclareOrDefineAReservedIdentifierQuery()
  }
}
