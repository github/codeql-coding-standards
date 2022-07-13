/**
 * @id cpp/autosar/goto-to-catch-block
 * @name M15-0-3: Control shall not be transferred into a try or catch block using a goto statement
 * @description Using a goto to transfer control to a try or catch block is ill-formed.
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

from GotoStmt gs
where
  not isExcluded(gs, Exceptions1Package::gotoToCatchBlockQuery()) and
  exists(Stmt catchOrTryBody |
    catchOrTryBody = any(TryStmt ts).getStmt()
    or
    catchOrTryBody instanceof CatchBlock
  |
    // Jump target is within this catch or try body
    catchOrTryBody = gs.getTarget().getEnclosingElement*() and
    // But the goto is outside the try/catch
    not catchOrTryBody = gs.getEnclosingElement*()
  )
select gs, "Goto transfers control to within a try or catch block."
