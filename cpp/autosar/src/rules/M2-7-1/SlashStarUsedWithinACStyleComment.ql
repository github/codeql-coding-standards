/**
 * @id cpp/autosar/slash-star-used-within-ac-style-comment
 * @name M2-7-1: The character sequence /* shall not be used within a C-style comment
 * @description The presence of a nested /* comment can indicate accidentally commented out code.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m2-7-1
 *       maintainability
 *       readability
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from CStyleComment c
where
  not isExcluded(c, CommentsPackage::slashStarUsedWithinACStyleCommentQuery()) and
  exists(c.getContents().regexpFind("./\\*", _, _))
select c, "C-style /* comment includes nested /*."
