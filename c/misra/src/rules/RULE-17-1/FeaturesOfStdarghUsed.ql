/**
 * @id c/misra/features-of-stdargh-used
 * @name RULE-17-1: The features of 'stdarg.h' shall not be used
 * @description The use of the features of 'stdarg.h' may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-1
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Locatable use, string name, string kind
where
  not isExcluded(use, BannedPackage::featuresOfStdarghUsedQuery()) and
  (
    exists(VarArgsExpr va | use = va and name = va.toString() and kind = "built-in operation")
    or
    exists(Variable v |
      v.getType().getName() = "va_list" and
      name = "va_list" and
      use = v and
      kind = "type"
    )
  )
select use, "Use of banned " + kind + " " + name + "."
