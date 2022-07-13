/**
 * @id cpp/autosar/for-loop-initializes-non-loop-counter
 * @name A6-5-4: For-init-statement should not perform actions other than loop-counter initialization
 * @description For-init-statement and expression should not perform actions other than loop-counter
 *              initialization and modification.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a6-5-4
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from ForStmt fs
where
  not isExcluded(fs, LoopsPackage::forLoopInitializesNonLoopCounterQuery()) and
  (
    // for (int i = 0, j = 0; ...; ...)
    count(fs.getADeclaration()) > 1
    or
    // for (i = 0, j = 0; ...; ...)
    exists(fs.getInitialization().(ExprStmt).getExpr().(CommaExpr))
  )
select fs, "For loop initializes multiple variables."
