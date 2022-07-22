/**
 * @id c/misra/octal-constants-used
 * @name RULE-7-1: Octal constants shall not be used
 * @description The use of octal constants affects the readability of the program and should not be
 *              used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-1
 *       readability
 *       correctness
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from OctalLiteral octal
where not isExcluded(octal, BannedPackage::octalConstantsUsedQuery())
select octal, "Use of banned $@ constant.", octal, "octal"
