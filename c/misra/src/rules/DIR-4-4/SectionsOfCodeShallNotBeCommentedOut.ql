/**
 * @id c/misra/sections-of-code-shall-not-be-commented-out
 * @name DIR-4-4: Sections of code should not be commented out
 * @description Commented out code may become out of date leading to developer confusion.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/dir-4-4
 *       maintainability
 *       readability
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.sectionsofcodeshallnotbecommentedout.SectionsOfCodeShallNotBeCommentedOut

class SectionsOfCodeShallNotBeCommentedOutQuery extends SectionsOfCodeShallNotBeCommentedOutSharedQuery {
  SectionsOfCodeShallNotBeCommentedOutQuery() {
    this = SyntaxPackage::sectionsOfCodeShallNotBeCommentedOutQuery()
  }
}
