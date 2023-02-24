/**
 * @id c/misra/string-literal-assigned-to-non-const-char
 * @name RULE-7-4: A string literal shall only be assigned to a pointer to const char.
 * @description Assigning string literal to a variable with type other than a pointer to const char
 *              and modifying it causes undefined behavior .
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::stringLiteralAssignedToNonConstCharQuery()) and
select
