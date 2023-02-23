/**
 * Provides a library which includes a `problems` predicate for reporting goto statements that jump to labels
 * declared later in the same funciton.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class GotoStatementConditionSharedQuery extends Query { }

Query getQuery() { result instanceof GotoStatementConditionSharedQuery }

query predicate problems(
  GotoStmt goto, string message, GotoStmt gotoLocation, string gotoLabel, Stmt target,
  string targetLabel
) {
  not isExcluded(goto, getQuery()) and
  target = goto.getTarget() and
  exists(Location targetLoc, Location gotoLoc |
    targetLoc = target.getLocation() and
    gotoLoc = goto.getLocation() and
    targetLoc.getFile() = gotoLoc.getFile()
  |
    // Starts on a previous line
    targetLoc.getStartLine() < gotoLoc.getEndLine()
    or
    // Starts on the same line, but an earlier column
    targetLoc.getStartLine() = gotoLoc.getEndLine() and
    targetLoc.getEndColumn() < gotoLoc.getStartColumn()
  ) and
  goto = gotoLocation and
  message = "The $@ statement jumps to a $@ that is not declared later in the same function." and
  gotoLabel = goto.getName() and
  targetLabel = target.toString()
}
