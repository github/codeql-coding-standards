import cpp
import codingstandards.cpp.types.FunctionType

/**
 * A class representing an expression that has a function pointer type. This can be a function
 * access, a variable access, or any expression that has a function pointer type.
 */
abstract class FunctionExpr extends Expr {
  /** Any element that could represent the function, for example, a variable or an expression. */
  abstract Element getFunction();

  /** A name or string that describes the function. */
  abstract string describe();

  /** Get calls of this function */
  abstract Call getACall();
}

/**
 * A function access is an an expression of function type where we know the function.
 */
class SimpleFunctionAccess extends FunctionExpr, FunctionAccess {
  override Element getFunction() { result = this.getTarget() }

  override string describe() { result = "Address of function " + this.getTarget().getName() }

  override FunctionCall getACall() { result.getTarget() = this.getTarget() }
}

/**
 * An access of a variable that has a function pointer type is also a function expression, for which
 * we can track certain properties of the function.
 */
class FunctionVariableAccess extends FunctionExpr, VariableAccess {
  FunctionVariableAccess() { this.getUnderlyingType() instanceof FunctionType }

  override Element getFunction() { result = this.getTarget() }

  override string describe() { result = "Function pointer variable " + this.getTarget().getName() }

  override ExprCall getACall() { result.getExpr().(VariableAccess).getTarget() = this.getTarget() }
}

/**
 * A function typed expression that is not a function access or a variable access.
 */
class FunctionTypedExpr extends FunctionExpr {
  FunctionTypedExpr() {
    this.getUnderlyingType() instanceof FunctionType and
    not this instanceof FunctionAccess and
    not this instanceof VariableAccess
  }

  override Element getFunction() { result = this }

  override string describe() { result = "Expression with function pointer type" }

  override ExprCall getACall() { result.getExpr() = this }
}
