/**
 * @id c/misra/language-not-encapsulated-and-isolated
 * @name DIR-4-3: Assembly language shall be encapsulated and isolated
 * @description Failing to encapsulate assembly language limits the portability, reliability, and
 *              readability of programs.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/dir-4-3
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from AsmStmt asm
where
  not isExcluded(asm, Language1Package::languageNotEncapsulatedAndIsolatedQuery()) and
  not exists(asm.getEnclosingFunction())
  or
  // in concept statements within the body constitute intermingling assembly,
  // rather than expressions and are more general.
  exists(Stmt sp | sp = asm.getEnclosingFunction().getEntryPoint().getASuccessor*() |
    not sp instanceof AsmStmt and not sp instanceof ReturnStmt and not sp instanceof BlockStmt
  )
select asm, "Usage of non-isolated and non-encapsulated assembly language."
