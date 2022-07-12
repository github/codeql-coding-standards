/**
 * @id cpp/autosar/switch-compound-condition
 * @name M6-3-1: The statement forming the body of a switch shall be a compound statement
 * @description If the body of a switch is not enclosed in braces, then this can lead to incorrect
 *              execution, and hard for developers to maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-3-1
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

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

from SwitchStmt switch
where
  not isExcluded(switch, ConditionalsPackage::switchCompoundConditionQuery()) and
  (
    switch.getStmt() instanceof ArtificialBlock or
    not switch.getStmt() instanceof BlockStmt
  )
select switch, "Switch body not enclosed within braces."
