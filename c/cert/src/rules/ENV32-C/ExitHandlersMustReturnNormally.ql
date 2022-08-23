/**
 * @id c/cert/exit-handlers-must-return-normally
 * @name ENV32-C: All exit handlers must return normally
 * @description Exit handlers must terminate by returning as a nested call to an exit function is
 *              undefined behavior.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/env32-c
 *       correcteness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

class ExitFunctionCall extends FunctionCall {
  ExitFunctionCall() { this.getTarget().hasGlobalName(["_Exit", "exit", "quick_exit", "longjmp"]) }
}

class RegisteredAtexit extends FunctionAccess {
  RegisteredAtexit() {
    exists(FunctionCall ae |
      this = ae.getArgument(0).(FunctionAccess) and
      ae.getTarget().hasGlobalName(["atexit", "at_quick_exit"])
    )
  }
}

/**
 * An `edges` predicate to support the `path-problem` query. Reports edges between
 * `FunctionAccess`/`FunctionCall` nodes and their target `Function` and between
 * `Function` and `FunctionCall` in their body.
 */
query predicate edges(ControlFlowNode a, ControlFlowNode b) {
  a.(FunctionAccess).getTarget() = b
  or
  a.(FunctionCall).getTarget() = b and
  // avoid referencing library functions
  b.(Function).calls(any(ExitFunctionCall e).getTarget())
  or
  a.(Function).calls(_, b)
}

from RegisteredAtexit hr, Function f, ExitFunctionCall e
where edges(hr, f) and edges+(f, e)
select f, hr, e, "The function is $@ and $@. It must instead terminate by returning.", hr,
  "registered as `exit handler`", e, "calls an `exit function`"
