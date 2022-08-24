/**
 * @id c/cert/exit-handlers-must-return-normally
 * @name ENV32-C: All exit handlers must return normally
 * @description Exit handlers must terminate by returning, as a nested call to an exit function is
 *              undefined behavior.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/env32-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

class ExitFunction extends Function {
  ExitFunction() { this.hasGlobalName(["_Exit", "exit", "quick_exit", "longjmp"]) }
}

class ExitFunctionCall extends FunctionCall {
  ExitFunctionCall() { this.getTarget() instanceof ExitFunction }
}

class RegisteredAtexit extends FunctionAccess {
  RegisteredAtexit() {
    exists(FunctionCall ae |
      this = ae.getArgument(0).(FunctionAccess) and
      ae.getTarget().hasGlobalName(["atexit", "at_quick_exit"])
    )
  }
}

/*
 * Nodes of type Function, FunctionCall or FunctionAccess that \
 * are reachable from a redistered atexit handler and
 * can reach an exit function.
 */
class InterestingNode extends ControlFlowNode {
  InterestingNode() {
    exists(Function f |
      (
        this.(Function) = f and
        // exit functions are not part of edges
        not this = any(ExitFunction ec)
        or
        this.(FunctionCall).getTarget() = f
        or
        this.(FunctionAccess).getTarget() = f
      ) and
      // reaches an exit function
      f.calls*(any(ExitFunction e)) and
      // is reachable from a registered atexit function
      exists(RegisteredAtexit re | re.getTarget().calls*(f))
    )
  }
}

/**
 * An `edges` predicate to support the `path-problem` query. Reports edges between
 * `FunctionAccess`/`FunctionCall` nodes and their target `Function` and between
 * `Function` and `FunctionCall` in their body.
 */
query predicate edges(InterestingNode a, InterestingNode b) {
  a.(FunctionAccess).getTarget() = b
  or
  a.(FunctionCall).getTarget() = b
  or
  a.(Function).calls(_, b)
}

from RegisteredAtexit hr, Function f, ExitFunctionCall e
where edges(hr, f) and edges+(f, e)
select f, hr, e, "The function is $@ and $@. It must instead terminate by returning.", hr,
  "registered as `exit handler`", e, "calls an `exit function`"
