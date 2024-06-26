/**
 * @id cpp/misra/line-splicing-used-in-comments
 * @name RULE-5-7-3: Line-splicing shall not be used in // comments
 * @description Line-splicing shall not be used in // comments.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-7-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.linesplicingusedincomments_shared.LineSplicingUsedInComments_shared

class LineSplicingUsedInCommentsQuery extends LineSplicingUsedInComments_sharedSharedQuery {
  LineSplicingUsedInCommentsQuery() {
    this = ImportMisra23Package::lineSplicingUsedInCommentsQuery()
  }
}
