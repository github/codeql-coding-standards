/** A module to reason about functions, such as well-known functions. */

import cpp

/**
 * A function whose name is suggestive that it counts the number of bits set.
 */
class PopCount extends Function {
  PopCount() { this.getName().toLowerCase().matches("%popc%nt%") }
}

/**
 * A function the user explicitly declared, though its body may be compiler-generated.
 */
class UserDeclaredFunction extends Function {
  UserDeclaredFunction() {
    not isDeleted() and
    (
      // Not compiler generated is explicitly declared
      not isCompilerGenerated()
      or
      // Closure functions are compiler generated, but the user
      // explicitly declared the lambda expression.
      exists(Closure c | c.getLambdaFunction() = this)
      or
      // Indicates users specifically wrote "= default"
      isDefaulted()
    )
  }
}

/**
 * An expression that is effectively a function access.
 *
 * There are more ways to effectively access a function than a basic `FunctionAcess`, for instance
 * taking the address of a function access, and declaring/converting a lambda function.
 */
abstract class FunctionAccessLikeExpr extends Expr {
  abstract Function getFunction();
}

/**
 * A basic function access expression.
 */
class FunctionAccessExpr extends FunctionAccess, FunctionAccessLikeExpr {
  override Function getFunction() { result = this.getTarget() }
}

/**
 * Taking the address of a function access in effectively a function access.
 */
class FunctionAddressExpr extends AddressOfExpr, FunctionAccessLikeExpr {
  Function func;

  FunctionAddressExpr() { func = getOperand().(FunctionAccessLikeExpr).getFunction() }

  override Function getFunction() { result = func }
}

/**
 * An expression that declares a lambda function is essentially a function access of the lambda
 * function body.
 */
class LambdaValueExpr extends LambdaExpression, FunctionAccessLikeExpr {
  override Function getFunction() { result = this.(LambdaExpression).getLambdaFunction() }
}

/**
 * When a lambda is converted via conversion operator to a function pointer, it is
 * effectively a function access of the lambda function.
 */
class LambdaConversionExpr extends FunctionCall, FunctionAccessLikeExpr {
  Function func;

  LambdaConversionExpr() {
    getTarget() instanceof ConversionOperator and
    func = getQualifier().(LambdaValueExpr).getFunction()
  }

  override Function getFunction() { result = func }
}
