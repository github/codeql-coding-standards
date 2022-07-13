/**
 * @id cpp/autosar/single-line-comment-ends-with-slash
 * @name A2-7-1: The character \ shall not occur as a last character of a C++ comment
 * @description If the character \ occurs as the last character of a C++ comment, the comment will
 *              continue onto the next line, possibly unexpectedly.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-7-1
 *       correctness
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from CppStyleComment c
where
  not isExcluded(c, CommentsPackage::singleLineCommentEndsWithSlashQuery()) and
  exists(c.getContents().regexpFind("\\\n", _, _))
select c, "C++ comment includes \\ as the last character of a line"
