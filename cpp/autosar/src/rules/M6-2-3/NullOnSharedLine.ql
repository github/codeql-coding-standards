/**
 * @id cpp/autosar/null-on-shared-line
 * @name M6-2-3: Before preprocessing, a null statement shall only occur on a line by itself
 * @description Before preprocessing, a null statement shall only occur on a line by itself; it may
 *              be followed by a comment, provided that the first character following the null
 *              statement is a white-space character.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-2-3
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import EmptyStatementTokenOrder

/*
 * This query is concerned with whether tokens occur on the same line as an empty statement.
 * Unfortunately, the CodeQL C++ model of the program does not store tokens, so we cannot simply
 * query for token locations on the same line.
 *
 * Instead, we try to determine where the tokens occur based on the locations provided on AST
 * elements. In particular, we identify the elements that contain the "predecessor" and
 * "successor" tokens for our empty statement. For example, in:
 * ```
 * 0; ;
 * ```
 * We determine that the predecessor of our empty statement is `0;`, which is an `ExprStmt`. In this
 * case we can identify the location of the predecessor token by finding the end location of the
 * predecessor element. We can then compare that with the empty statement location to determine
 * whether they appear on the same line.
 *
 * What makes this somewhat trickier is cases where the owner of the predecessor or successor token
 * is either an ancestor of the empty statement, or a successor of an ancestor statement. Consider:
 * ```
 * { ;
 * }
 * ```
 * In this case, the token that occurs before the `;` empty statement is the opening brace of the
 * parent `BlockStmt`. However, `BlockStmt` does not explicitly store the location of the start and
 * end braces - instead, the location encompasses the entire block, so we have to deduce the
 * location of the opening brace from the start line/start column of the `BlockStmt`.
 *
 * Successor cases can be even more complex, because the next token can belong to a distant ancestor:
 * ```
 * {
 *   if (x)
 *     if (y)
 *       if (z)
 *         ; } // NON_COMPLIANT
 * ```
 * Or can even belong to a successor of an ancestor:
 * ```
 * {
 *   if (x)
 *     if (y)
 *       if (z)
 *         ; 0; // NON_COMPLIANT - successor of `if (x) ...`
 * }
 * ```
 *
 * Unfortunately, in some cases it's not possible to find a suitable location, because the C++
 * extractor has omitted the information. For example:
 * ```
 * if (x
 *    ) ;
 * ```
 * In this case, the element predecessor of the `EmptyStmt` is the condition `x`, but the location
 * of `x` does not include the `)` token. In fact, the location of the `)` is not recorded in the
 * database anywhere, so we cannot possibly detect this case. However, I don't think this is a
 * particularly common way to contravene this rule, so not a huge problem!
 *
 * The situation for comments preceding/succeeding empty statements is a little easier - we can use
 * `Comment.getCommentedElement()` to identify the relevant comments, and use the locations to
 * identify the problematic cases.
 */

/** An empty statement which is not on a line by itself. */
abstract class EmptyStmtWithFriends extends EmptyStmt {
  EmptyStmtWithFriends() {
    // This rule is specifically before pre-processing, so only report results not affected by macros
    not isAffectedByMacro()
  }
}

/** An `EmptyStmt` where a non-comment token occurs before the empty statement on the same line. */
class EmptyStmtWithTokenBefore extends EmptyStmtWithFriends {
  EmptyStmtWithTokenBefore() {
    exists(Element before, TokenOrder::TokenLocation tokenLocation |
      before = TokenOrder::getPredecessorToken(this, tokenLocation)
    |
      // The predecessor is the last token of the previous element, for example:
      // ```
      // 0; ;
      // ```
      tokenLocation = TokenOrder::EndToken() and
      before.getLocation().getEndLine() = getLocation().getStartLine()
      or
      // The predecessor is the first token of the parent element, for example:
      // ```
      // { ;
      // }
      // ```
      tokenLocation = TokenOrder::StartToken() and
      before.getLocation().getStartLine() = getLocation().getStartLine()
    )
  }
}

/** An `EmptyStmt` where a non-comment token occurs after the empty statement on the same line. */
class EmptyStmtWithTokenAfter extends EmptyStmtWithFriends {
  EmptyStmtWithTokenAfter() {
    exists(Element after, TokenOrder::TokenLocation tokenLocation |
      after = TokenOrder::getSuccessorToken(this, tokenLocation)
    |
      // The successor is the last token of an ancestor element, for example:
      // ```
      // 0; ;
      // ```
      tokenLocation = TokenOrder::EndToken() and
      getLocation().getEndLine() = after.getLocation().getEndLine()
      or
      // The successor is the start token of the next element
      tokenLocation = TokenOrder::StartToken() and
      getLocation().getEndLine() = after.getLocation().getStartLine()
    )
  }
}

/** An empty stmt which is directly followed by a comment, with no whitespace gap. */
class EmptyStmtWithNoWhitespaceTrailingComment extends EmptyStmtWithFriends {
  EmptyStmtWithNoWhitespaceTrailingComment() {
    // Following comment with no whitespace gap
    exists(Comment c |
      c.getCommentedElement() = this and
      exists(Location emptyLoc, Location commentLoc |
        emptyLoc = this.getLocation() and
        commentLoc = c.getLocation()
      |
        emptyLoc.getEndLine() = commentLoc.getStartLine() and
        emptyLoc.getEndColumn() + 1 = commentLoc.getStartColumn()
      )
    )
  }
}

/** An empty stmt preceded by a comment on the same line. */
class EmptyStmtWithCommentBefore extends EmptyStmtWithFriends {
  EmptyStmtWithCommentBefore() {
    // Comment preceding the empty statement on the same line
    exists(Comment c |
      c.getCommentedElement() = this and
      exists(Location emptyLoc, Location commentLoc |
        emptyLoc = this.getLocation() and
        commentLoc = c.getLocation()
      |
        commentLoc.getEndLine() = emptyLoc.getStartLine() and
        commentLoc.getEndColumn() < emptyLoc.getStartColumn()
      )
    )
  }
}

from EmptyStmtWithFriends es
where not isExcluded(es, CommentsPackage::nullOnSharedLineQuery())
select es, "Empty statement is not on a line by itself."
