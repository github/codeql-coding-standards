/**
 * @id c/cert/variables-inside-switch-statement
 * @name DCL41-C: Do not declare variables inside a switch statement before the first case label
 * @description Declaring a variable in a switch statement before the first case label can result in
 *              reading uninitialized memory which is undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl41-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from SwitchCase case, SwitchStmt stmt, VariableDeclarationEntry d
where
  not isExcluded(d, Declarations2Package::variablesInsideSwitchStatementQuery()) and
  case.getSwitchStmt() = stmt and
  //first case
  not exists(case.getPreviousSwitchCase()) and
  exists(string filepath, int declarationLine, int caseLine, int stmtLine |
    d.getLocation().hasLocationInfo(filepath, declarationLine, _, _, _) and
    stmt.getLocation().hasLocationInfo(filepath, stmtLine, _, _, _) and
    case.getLocation().hasLocationInfo(filepath, caseLine, _, _, _) and
    declarationLine > stmtLine and
    declarationLine < caseLine
  )
select d, "Declaration is located in switch $@.", stmt, "statement"
