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
import codingstandards.cpp.rules.linesplicingusedincomments_shared.LineSplicingUsedInComments_shared

class SingleLineCommentEndsWithSlashQuery extends LineSplicingUsedInComments_sharedSharedQuery {
  SingleLineCommentEndsWithSlashQuery() {
    this = CommentsPackage::singleLineCommentEndsWithSlashQuery()
  }
}
