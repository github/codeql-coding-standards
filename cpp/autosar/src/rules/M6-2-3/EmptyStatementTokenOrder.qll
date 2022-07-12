/**
 * A `module` for predecessor and successor relations according to the order of tokens in the file.
 *
 * `getPredecessorToken` and `getSuccessorToken` respectively report the `Element`s associated with
 * the token that appears before or after the `EmptyStmt`. Note: for `EmptyStmt`s that appear in
 * composite `Stmt`s which are not `BlockStmt`s we provide a best effort match, based on what is
 * available in the database. Most notably, `IfStmt`s and similar do not consider the `(` `)` tokens
 * on conditions, e.g. for `if (x) ;`, we only consider the location of `x`, not the brackets around
 * `x`. This is because we lack good information in the database.
 *
 * This module does not handle the GNU only `StmtExpr` class - for simplicity, we assume that only
 * `Stmt`s are parents of `Stmt`s
 */

import cpp

module TokenOrder {
  /**
   * A `Stmt` which is either an `EmptyStmt` or the transitive parent of an `EmptyStmt`.
   *
   * Used to restrict our analysis of successor tokens to only elements which are of interest to
   * this query.
   */
  class EmptyStmtOrParent extends Stmt {
    EmptyStmtOrParent() {
      this instanceof EmptyStmt
      or
      this.getAChild() instanceof EmptyStmtOrParent
    }
  }

  /** Whether we're interested in the start or end token of an associated `Element`. */
  newtype TokenLocation =
    StartToken() or
    EndToken()

  /** Gets the `Element` which is associated with the predecessor token for `s`. */
  Element getPredecessorToken(EmptyStmt s, TokenLocation tokenLoc) {
    exists(Stmt parent, int i | s = parent.getChild(i) |
      // The empty statement is the first child of the parent, so the Token predecessor is the start
      // token for the parent
      not exists(parent.getChild(i - 1)) and
      result = parent and
      tokenLoc = StartToken()
      or
      // The empty statement has a sibling at the previous index, so the end token is the predecessor
      exists(Element pred |
        pred = parent.getChild(i - 1) and
        tokenLoc = EndToken()
      |
        not pred instanceof TryStmt and
        result = pred
        or
        // For `TryStmt`s, the location of the try does not include any of the catch clauses. We
        // therefore identify the last catch clause as the element containing the last token
        exists(TryStmt ts |
          ts = pred and
          result = ts.getCatchClause(ts.getNumberOfCatchClauses() - 1)
        )
      )
    )
  }

  /** Gets the `Element` which is associated with the predecessor token for `s`. */
  Element getSuccessorToken(EmptyStmtOrParent s, TokenLocation tokenLoc) {
    exists(Stmt parent, int i | s = parent.getChild(i) |
      // The empty statement is the last child of the parent
      not exists(parent.getChild(i + 1)) and
      (
        // If the parent is the block statement, the Token successor is the end of the block
        if parent instanceof BlockStmt
        then
          result = parent and
          tokenLoc = EndToken()
        else
          // Otherwise, it's the Token successor of the parent
          result = getSuccessorToken(parent, tokenLoc)
      )
      or
      // The empty statement has a sibling at the next index, so the start token is the successor
      result = parent.getChild(i + 1) and
      tokenLoc = StartToken()
    )
  }
}
