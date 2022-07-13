/**
 * @id cpp/autosar/switch-to-catch-block
 * @name M15-0-3: Control shall not be transferred into a try or catch block using a switch statement
 * @description Using a switch statement to transfer control to a try or catch block is ill-formed.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m15-0-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from SwitchCase sc
where
  not isExcluded(sc, Exceptions1Package::switchToCatchBlockQuery()) and
  exists(Stmt catchOrTryBody |
    catchOrTryBody = any(TryStmt ts).getStmt()
    or
    catchOrTryBody instanceof CatchBlock
  |
    // Jump target is within this catch or try body
    catchOrTryBody = sc.getEnclosingElement*() and
    // But the goto is outside the try/catch
    not catchOrTryBody = sc.getSwitchStmt().getEnclosingElement*()
  )
select sc, "Switch case transfers control within a try or catch block."
