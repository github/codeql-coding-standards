/**
 * @id cpp/misra/sections-of-code-should-not-be-commented-out
 * @name DIR-5-7-2: Sections of code should not be “commented out”
 * @description Commented out code may become out of date leading to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/dir-5-7-2
 *       maintainability
 *       readability
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.sectionsofcodeshallnotbecommentedout.SectionsOfCodeShallNotBeCommentedOut

class SectionsOfCodeShouldNotBeCommentedOutQuery extends SectionsOfCodeShallNotBeCommentedOutSharedQuery
{
  SectionsOfCodeShouldNotBeCommentedOutQuery() {
    this = ImportMisra23Package::sectionsOfCodeShouldNotBeCommentedOutQuery()
  }
}
