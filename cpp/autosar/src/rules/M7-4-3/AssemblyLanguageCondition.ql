/**
 * @id cpp/autosar/assembly-language-condition
 * @name M7-4-3: Assembly language shall be encapsulated and isolated
 * @description Using assembly language that is not encapsulated and isolated leads to portability
 *              issues.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m7-4-3
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import cpp

from AsmStmt asm
where
  not isExcluded(asm, FunctionsPackage::assemblyLanguageConditionQuery()) and
  not asm.isAffectedByMacro() and
  not exists(Function f |
    asm.getEnclosingFunction() = f and
    forall(Stmt s | s.getEnclosingFunction() = f |
      s instanceof AsmStmt or
      s instanceof BlockStmt or
      s instanceof DeclStmt or
      s instanceof ReturnStmt
    )
  )
select asm,
  "The assembler instruction is not isolated and encapsulated in an assembly-only function"
