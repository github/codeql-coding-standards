/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class GotoStatementConditionSharedQuery extends Query { }

Query getQuery() { result instanceof GotoStatementConditionSharedQuery }

query predicate problems(GotoStmt goto, string message, Stmt target, string targetLabel) {
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
    )
    and message = "The goto jumps to the label $@ that is not declared later in the same function." and targetLabel = target.toString()
}





// from GotoStmt goto, Stmt target
// where
//   not isExcluded(goto, ConditionalsPackage::gotoStatementJumpConditionQuery()) and
//   target = goto.getTarget() and
//   exists(Location targetLoc, Location gotoLoc |
//     targetLoc = target.getLocation() and
//     gotoLoc = goto.getLocation() and
//     targetLoc.getFile() = gotoLoc.getFile()
//   |
//     // Starts on a previous line
//     targetLoc.getStartLine() < gotoLoc.getEndLine()
//     or
//     // Starts on the same line, but an earlier column
//     targetLoc.getStartLine() = gotoLoc.getEndLine() and
//     targetLoc.getEndColumn() < gotoLoc.getStartColumn()
//   )
// select goto, "The goto jumps to the label $@ that is not declared later in the same function.",
//   target, goto.getName()
