/**
 * Provides a library with a `problems` predicate for the following issue:
 * If the body of a switch is not enclosed in braces, then this can lead to incorrect
 * execution, and hard for developers to maintain.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class SwitchCompoundConditionSharedQuery extends Query { }

Query getQuery() { result instanceof SwitchCompoundConditionSharedQuery }

/**
 * Class to differentiate between extractor generated blockstmt and actual blockstmt. The extractor
 * will generate an artificial blockstmt when there is a single case and statement, e.g.
 * ```
 * switch(x)
 *   case 1:
 *     f();
 * ```
 * This is because our AST model considers the `case` to be a statement in its own right, so the
 * extractor needs an aritifical block to hold both the case and the statement.
 */
class ArtificialBlock extends BlockStmt {
  ArtificialBlock() {
    exists(Location block, Location firstStatement |
      block = getLocation() and firstStatement = getStmt(0).getLocation()
    |
      // We can identify artificial blocks as those where the start of the statement is at the same
      // location as the start of the first statement in the block i.e. there was no opening brace.
      block.getStartLine() = firstStatement.getStartLine() and
      block.getStartColumn() = firstStatement.getStartColumn()
    )
  }
}

query predicate problems(SwitchStmt switch, string message) {
  (
    switch.getStmt() instanceof ArtificialBlock or
    not switch.getStmt() instanceof BlockStmt
  ) and
  not isExcluded(switch, getQuery()) and
  message = "Switch body not enclosed within braces."
}
