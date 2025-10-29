/**
 * @id c/misra/octal-and-hexadecimal-escape-sequences-not-terminated
 * @name RULE-4-1: Octal and hexadecimal escape sequences shall be terminated
 * @description Not explicitly terminating octal and hexadecimal escape sequences can results in
 *              developer confusion and lead to programming errors.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1
 *       maintainability
 *       readability
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.nonterminatedescapesequences.NonTerminatedEscapeSequences

class OctalAndHexadecimalEscapeSequencesNotTerminatedQuery extends NonTerminatedEscapeSequencesSharedQuery
{
  OctalAndHexadecimalEscapeSequencesNotTerminatedQuery() {
    this = SyntaxPackage::octalAndHexadecimalEscapeSequencesNotTerminatedQuery()
  }
}
