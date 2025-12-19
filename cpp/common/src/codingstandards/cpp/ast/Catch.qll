import cpp

CatchBlock getEarlierCatchBlock(CatchBlock cb) {
  exists(TryStmt try, int i, int j |
    cb = try.getCatchClause(j) and
    i < j and
    result = try.getCatchClause(i)
  )
}

/**
 * Get the body of a catch block, ie, the block of statements executed when the catch block is
 * entered.
 *
 * This is useful, for instance, for CFG traversal
 */
Stmt getCatchBody(CatchBlock cb) { result = cb.getChild(0) }
