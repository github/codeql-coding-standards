/**
 * @id c/misra/standard-header-file-tgmathh-used
 * @name RULE-21-11: The standard header file 'tgmath.h' shall not be used
 * @description The use of the header file 'tgmath.h' may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-11
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Macro m, MacroInvocation mi
where
  not isExcluded(mi, BannedPackage::standardHeaderFileTgmathhUsedQuery()) and
  mi.getMacro() = m and
  m.getFile().getBaseName() = "tgmath.h" and
  not mi.getParentInvocation().getMacro().getFile().getBaseName() = "tgmath.h"
select mi, "Call to banned macro " + m.getName() + "."
