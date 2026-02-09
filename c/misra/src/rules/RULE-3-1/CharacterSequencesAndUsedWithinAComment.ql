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
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

/* Character sequence is banned from all comment types */
class IllegalCommentSequence extends string {
  IllegalCommentSequence() { this = "/*" }
}

/* A regexp to check for illegal C-style comments */
class IllegalCCommentRegexp extends string {
  IllegalCCommentRegexp() {
    // Regexp to match "//" in C-style comments, which do not appear to be URLs. General format
    // uses negative lookahead/lookbehind to match like `.*(?<!HTTP:)//(?!GITHUB.).*`. Broken down
    // into parts:
    //  - `.*PATTERN.*` - look for the pattern anywhere in the comment.
    //  - `(?<![a-zA-Z]:)` - negative lookbehind, exclude "http://github.com" by seeing "p:".
    //  - `//` - the actual illegal sequence.
    //  - `(?!(pattern))` - negative lookahead, exclude "http://github.com" by seeing "github.".
    //  - `[a-zA-Z0-9\\-]+\\\\.` - Assume alphanumeric/hyphen followed by '.' is a domain name.
    this = ".*(?<![a-zA-Z]:)//(?![a-zA-Z0-9\\-]+\\\\.).*"
  }

  string getDescription() { result = "//" }
}

from Comment comment, string illegalSequence
where
  not isExcluded(comment, SyntaxPackage::characterSequencesAndUsedWithinACommentQuery()) and
  (
    exists(IllegalCommentSequence c | illegalSequence = c |
      comment.getContents().indexOf(illegalSequence) > 1
    )
    or
    exists(IllegalCCommentRegexp c | illegalSequence = c.getDescription() |
      comment.(CStyleComment).getContents().regexpMatch(c)
    )
  )
select comment, "Comment contains an illegal sequence '" + illegalSequence + "'"
