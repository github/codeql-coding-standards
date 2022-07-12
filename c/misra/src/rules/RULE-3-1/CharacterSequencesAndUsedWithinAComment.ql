/**
 * @id c/misra/character-sequences-and-used-within-a-comment
 * @name RULE-3-1: The character sequences /* and // shall not be used within a comment
 * @description A /* or // character sequence within a comment is sometimes indicative of a missed
 *              comment and should not be allowed.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-3-1
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

class IllegalCCommentCharacter extends string {
  IllegalCCommentCharacter(){
    this = "/*" or 
    this = "//"
  }
}

class IllegalCPPCommentCharacter extends string {
  IllegalCPPCommentCharacter(){
    this = "/*" 
  }
}

from Comment comment, string illegalSequence
where
  not isExcluded(comment, SyntaxPackage::characterSequencesAndUsedWithinACommentQuery()) 
  and 
  (
    exists(IllegalCCommentCharacter c | illegalSequence = c | comment.(CStyleComment).getContents().indexOf(illegalSequence) > 0) or
    exists(IllegalCPPCommentCharacter c | illegalSequence = c  | comment.(CppStyleComment).getContents().indexOf(illegalSequence) > 0) 
  )
select comment, "Comment contains an illegal sequence '" + illegalSequence + "'"
