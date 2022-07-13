/**
 * @id cpp/autosar/sections-of-code-commented-out
 * @name A2-7-2: Sections of code shall not be 'commented out'
 * @description Commented out code may become out of date leading to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-7-2
 *       maintainability
 *       readability
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.sectionsofcodeshallnotbecommentedout.SectionsOfCodeShallNotBeCommentedOut

class SectionsOfCodeCommentedOutQuery extends SectionsOfCodeShallNotBeCommentedOutSharedQuery {
  SectionsOfCodeCommentedOutQuery() {
    this = CommentsPackage::sectionsOfCodeCommentedOutQuery()
  }
}
