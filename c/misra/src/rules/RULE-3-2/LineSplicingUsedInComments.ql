/**
 * @id c/misra/line-splicing-used-in-comments
 * @name RULE-3-2: Line-splicing shall not be used in // comments
 * @description Entering a newline following a '\' character can erroneously commenting out regions
 *              of code.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-3-2
 *       maintainability
 *       readability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from CppStyleComment c
where
  not isExcluded(c, SyntaxPackage::lineSplicingUsedInCommentsQuery()) and
  (c.getContents().indexOf("\\") + 1) = c.getContents().indexOf("\n")
select c, "Line splicing in //-style comment."
