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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.ReservedNames

from Element e, string message
where
  not isExcluded(e, Declarations1Package::doNotDeclareAReservedIdentifierQuery()) and
  ReservedNames::C11::isAReservedIdentifier(e, message, true) and
  // Not covered by this rule - covered by Rule 21.2
  not e instanceof PreprocessorDirective
select e, message
