import cpp
import codeql.util.Boolean
import semmle.code.cpp.controlflow.Guards
import codingstandards.cpp.exprs.FunctionExprs

/**
 * A guard of the form: `if (funcPtr) funcPtr();`, e.g., a null check on a function before calling
 * that function.
 *
 * Note this does not consider the above to be a null function call guard if `funcPtr` is a
 * function name, as that could only be null via unusual linkage steps, and is not expected to be
 * an intentional null check.
 */
class NullFunctionCallGuard extends GuardCondition {
  FunctionExpr expr;

  NullFunctionCallGuard() {
    exists(BasicBlock block, Call guardedCall |
      (
        // Handles 'if (funcPtr != NULL)`:
        this.ensuresEq(expr, 0, block, false)
        or
        // Handles `if (funcPtr)` in C where no implicit conversion to bool exists:
        expr = this and
        expr.getFunction() instanceof Variable and
        this.controls(block, true)
      ) and
      guardedCall = expr.getACall() and
      block.contains(guardedCall)
    )
  }

  FunctionExpr getFunctionExpr() { result = expr }
}
