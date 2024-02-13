/*
 * A library customize models that model the flow of exceptions through the program.
 */

import cpp
private import codingstandards.cpp.exceptions.ExceptionFlow

/** A `ThrowingExpr` which is the origin of a exceptions in the program. */
abstract class OriginThrowingExpr extends ThrowingExpr { }

/**
 * A `FunctionCall` to an external function without an exception specification that *
 *  may throw an exception.
 */
abstract class ExternalUnderspecifiedFunctionCallThrowingExpr extends FunctionCall, ThrowingExpr { }

/**
 * An extensible predicate that describes functions that when called may throw an exception.
 */
extensible predicate throwingFunctionModel(
  string functionNamespaceQualifier, string functionTypeQualifier, string functionName,
  string exceptionNamespaceQualifier, string exceptionType
);

/**
 * A `FunctionCall` that may throw an exception of type `ExceptionType` as provded by
 * the extensible predicate `throwingFunctionModel`.
 */
private class ExternalFunctionCallThrowingExpr extends FunctionCall, ThrowingExpr {
  ExceptionType exceptionType;

  ExternalFunctionCallThrowingExpr() {
    exists(
      string functionNamespaceQualifier, string functionTypeQualifier, string functionName,
      string exceptionNamespaceQualifier, string exceptionTypeSpec
    |
      throwingFunctionModel(functionNamespaceQualifier, functionTypeQualifier, functionName,
        exceptionNamespaceQualifier, exceptionTypeSpec) and
      this.getTarget()
          .hasQualifiedName(functionNamespaceQualifier, functionTypeQualifier, functionName) and
      exceptionType.(Class).hasQualifiedName(exceptionNamespaceQualifier, exceptionTypeSpec)
    )
  }

  override ExceptionType getAnExceptionType() { result = exceptionType }
}

/** An expression which directly throws. */
class DirectThrowExprThrowingExpr extends DirectThrowExpr, OriginThrowingExpr {
  override ExceptionType getAnExceptionType() { result = getExceptionType() }
}

/** A `ReThrowExpr` which throws a previously caught exception. */
class ReThrowExprThrowingExpr extends ReThrowExpr, ThrowingExpr {
  predicate rethrows(CatchBlock cb, ExceptionType et, ThrowingExpr te) {
    // Find the nearest CatchBlock
    cb = getNearestCatch(this.getEnclosingStmt()) and
    // Find an `ExceptionType` which is caught by this catch block, and `ThrowingExpr` which throws that exception type
    catches(cb, te, et)
  }

  override ExceptionType getAnExceptionType() { rethrows(_, result, _) }

  CatchBlock getCatchBlock() { rethrows(result, _, _) }
}

/** An expression which calls a function which may throw an exception. */
class FunctionCallThrowingExpr extends FunctionCall, ThrowingExpr {
  override ExceptionType getAnExceptionType() {
    exists(Function target |
      target = getTarget() and
      result = getAFunctionThrownType(target, _) and
      // [expect.spec] states that throwing an exception type that is prohibited
      // by the specification will result in the program terminating, unless
      // a custom `unexpected_handler` is registered that throws an exception type
      // which is compatible with the dynamic exception specification, or the
      // dynamic exception specification lists `std::bad_exception`, in which case
      // a `std::bad_exception` is thrown.
      // As dynamic exception specifications and the `unexpected_handler` are both
      // deprecated in C++14 and removed in C++17, we assume a default
      // `std::unexpected` handler that calls `std::terminate` and therefore
      // do not propagate such exceptions to the call sites for the function.
      not (
        hasDynamicExceptionSpecification(target) and
        not result = getAHandledExceptionType(target.getAThrownType())
        or
        isNoExceptTrue(target)
      )
    )
    or
    result = this.(ExternalUnderspecifiedFunctionCallThrowingExpr).getAnExceptionType()
    or
    result = this.(ExternalFunctionCallThrowingExpr).getAnExceptionType()
  }
}

/** An `typeid` expression which may throw `std::bad_typeid`. */
private class TypeIdThrowingExpr extends TypeidOperator, OriginThrowingExpr {
  override ExceptionType getAnExceptionType() { result instanceof StdBadTypeId }
}

/** An `new[]` expression which may throw `std::bad_array_new_length`. */
private class NewThrowingExpr extends NewArrayExpr, OriginThrowingExpr {
  NewThrowingExpr() {
    // If the extent is known to be below 0 at runtime
    getExtent().getValue().toInt() < 0
    or
    // initializer has more elements than the array size
    getExtent().getValue().toInt() < getInitializer().(ArrayAggregateLiteral).getArraySize()
  }

  override ExceptionType getAnExceptionType() { result instanceof StdBadArrayNewLength }
}
