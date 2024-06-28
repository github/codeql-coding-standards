/**
 * @id cpp/misra/character-sequence-used-within-ac-style-comment
 * @name RULE-5-7-1: The character sequence /* shall not be used within a C-style comment
 * @description The character sequence /* shall not be used within a C-style comment.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-7-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.charactersequenceusedwithinacstylecomment_shared.CharacterSequenceUsedWithinACStyleComment_shared

class CharacterSequenceUsedWithinACStyleCommentQuery extends CharacterSequenceUsedWithinACStyleComment_sharedSharedQuery
{
  CharacterSequenceUsedWithinACStyleCommentQuery() {
    this = ImportMisra23Package::characterSequenceUsedWithinACStyleCommentQuery()
  }
}
