import cpp
import codingstandards.cpp.types.Type
import codingstandards.cpp.types.FunctionType

/**
 * Gets the `FunctionType` of an expression call.
 */
FunctionType getExprCallFunctionType(ExprCall call) {
  // A standard expression call
  // Returns a FunctionPointerIshType
  result = call.(ExprCall).getExpr().getType()
  or
  // An expression call using the pointer to member operator (.* or ->*)
  // This special handling is required because we don't have a CodeQL class representing the call
  // to a pointer to member function, but the right hand side is extracted as the -1 child of the
  // call.
  // Returns a RoutineType
  result = call.(ExprCall).getChild(-1).getType().(PointerToMemberType).getBaseType()
}

/**
 * An `Expr` that is used as an argument to a `Call`, and has helpers to handle with the differences
 * between `ExprCall` and `FunctionCall` cases.
 */
class CallArgumentExpr extends Expr {
  Call call;
  Type paramType;
  int argIndex;

  CallArgumentExpr() {
    this = call.getArgument(argIndex) and
    (
      paramType = call.getTarget().getParameter(argIndex).getType()
      or
      paramType = getExprCallFunctionType(call).getParameterType(argIndex)
    )
  }

  /**
   * Gets the `FunctionExpr` or `FunctionCall` that this argument appears in.
   */
  Call getCall() { result = call }

  /**
   * Gets the `Type` of the parameter corresponding to this argument, whether its based on the
   * target function or the function pointer type.
   */
  Type getParamType() { result = paramType }

  /**
   * Gets the argument index of this argument in the call.
   */
  int getArgIndex() { result = argIndex }

  /**
   * Gets the target `Function` if this is an argument to a `FunctionCall`.
   */
  Function getKnownFunction() { result = call.getTarget() }

  /**
   * Gets the target `Parameter` if this is an argument to a `FunctionCall`.
   */
  Parameter getKnownParameter() { result = call.getTarget().getParameter(argIndex) }
}
