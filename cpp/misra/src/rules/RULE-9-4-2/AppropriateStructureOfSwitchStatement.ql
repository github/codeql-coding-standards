/**
 * @id cpp/misra/appropriate-structure-of-switch-statement
 * @name RULE-9-4-2: The structure of a switch statement shall be appropriate
 * @description A switch statement should have an appropriate structure with proper cases, default
 *              labels, and break statements to ensure clear control flow and prevent unintended
 *              fall-through behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-4-2
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/allocated-target/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.SwitchStatement
import codingstandards.cpp.Noreturn

from SwitchStmt switch, string message
where
  not isExcluded(switch, StatementsPackage::appropriateStructureOfSwitchStatementQuery()) and
  /* 1. There is a statement that appears as an initializer and is not a declaration statement. */
  exists(Stmt initializer | initializer = switch.getInitialization() |
    not initializer instanceof DeclStmt
  ) and
  message = "contains a statement that is not a simple declaration"
  or
  /* 2. There is a switch case label that does not lead a branch (i.e. a switch case label is nested). */
  exists(SwitchCase case | case = switch.getASwitchCase() | case instanceof NestedSwitchCase) and
  message = "contains a switch label that is not directly within the switch body"
  or
  /* 3. There is a non-case label in a label group. */
  exists(SwitchCase case | case = switch.getASwitchCase() |
    case.getAStmt().getChildStmt*() instanceof LabelStmt
  ) and
  message = "contains a statement label that is not a case label"
  or
  /* 4. There is a statement before the first case label. */
  exists(Stmt switchBody | switchBody = switch.getStmt() |
    not switchBody.getChild(0) instanceof SwitchCase
  ) and
  message = "has a statement that is not a case label as its first element"
  or
  /* 5. There is a switch case whose terminator is not one of the allowed kinds. */
  exists(SwitchCase case, Stmt lastStmt |
    case = switch.getASwitchCase() and lastStmt = case.getLastStmt()
  |
    not (
      lastStmt instanceof BreakStmt or
      lastStmt instanceof ReturnStmt or
      lastStmt instanceof GotoStmt or
      lastStmt instanceof ContinueStmt or
      lastStmt.(ExprStmt).getExpr() instanceof ThrowExpr or
      lastStmt.(ExprStmt).getExpr().(Call).getTarget() instanceof NoreturnFunction or
      lastStmt.getAnAttribute().getName().matches("%fallthrough") // We'd like to consider compiler variants such as `clang::fallthrough`.
    )
  ) and
  message = "is missing a terminator that moves the control out of its body"
  or
  /* 6. The switch statement does not have more than two unique branches. */
  count(SwitchCase case |
    case = switch.getASwitchCase() and
    /*
     * If the next switch case is the following statement of this switch case, then the two
     * switch cases are consecutive and should be considered as constituting one branch
     * together.
     */

    not case.getNextSwitchCase() = case.getFollowingStmt()
  |
    case
  ) < 2 and
  message = "contains less than two branches"
  or
  /* 7-1. The switch statement is not an enum switch statement and is missing a default case. */
  not switch instanceof EnumSwitch and
  not switch.hasDefaultCase() and
  message = "lacks a default case"
  or
  /*
   * 7-2. The switch statement is an enum switch statement and is missing a branch for a
   * variant.
   */

  exists(switch.(EnumSwitch).getAMissingCase()) and
  message = "lacks a case for one of its variants"
select switch, "Switch statement " + message + "."
