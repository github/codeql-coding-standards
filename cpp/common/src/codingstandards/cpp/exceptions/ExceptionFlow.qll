/*
 * A library which models the flow of exceptions through the program.
 */

import cpp
import codingstandards.cpp.standardlibrary.Exceptions
import codingstandards.cpp.exceptions.ExceptionSpecifications
import codingstandards.cpp.exceptions.ExceptionFlowCustomizations
import ThirdPartyExceptions

/*
 * List of possible improvements:
 * - Consider exceptions that can be thrown due to virtual dispatch.
 * - Report only one `ThrowingExpr` for each `ExceptionType` thrown by a function.
 * - Represent `ExceptionType` as a `newtype` to allow more sophisticated modeling of:
 *   - `NestedException`s
 *   - Exceptions thrown by external APIs, where we don't have specific types in the database
 *     - An `AnyException`, for example to model external declarations like `void throwing_func() noexcept(false);`.
 * - `throw` expressions which return a "function returning T" or "an array of T", should be modeled as pointers
 *   - In some cases we may not have the pointer types for these in the database, so this may require a `newtype`
 *   - However, it may be that EDG already models this for us
 *   - As a result getUnspecifiedType() may be unnecessary in DirectThrowExpr.getExceptionType(), because EDG may already do this for us.
 * - Create a more sophisticated model of throw/rethrow:
 *   - `throw e;` can be a rethrow, if `e` flows from a catch handler.
 *   - Note: this means that a single throw expression can be _both_ a rethrow, and a regular throw.
 * - Model exception specifications contraventions:
 *   - A function which throws an exception which is prohibited by the exception specification will not continue to
 *     throw the exception as is currently modeled. Instead, it will either terminate the program, or it may rethrow
 *     either a std::bad_exception or a exception compatible with the specification, if a custom unexpected_handler is
 *     specified
 *   - Explicit calls to std::unexcepted could also be modeled here.
 * - `std::current_exception()` can contain a `std::bad_alloc` if a new expression fails in the implementation.
 * - Identify unreachable `ThrowingExpr`s, based on the control flow graph
 *   - Consider whether throws within unreachable catch blocks should be considered.
 * - Consider whether to model pointers to non-thrown ExceptionTypes
 * - Model more exceptions thrown by more standard library functions:
 *   - dynamic_cast - A `dynamic_cast` expression may throw `std::bad_cast`
 *   - typeid - consider excluding "safe" cases
 *   - Allocation - more sophisticated modeling of new array and new expression
 *   - Tuple assignment [20.4.2.2] For each tuple assignment operator, an exception is thrown only if the assignment of one of the types in Types throws an exception.
 *   - swap (20.4.2.3) if element-wise swap throws exception
 *   - bitset (20.6) - invalid_argument, out_of_range and overflow_errors
 *   - shared_ptr
 *     - std:bad_alloc or implementation-defined exception for out-of-resources other than memory
 *     - also bad_weak_ptr when r.expired()
 *   - bind (20.9.9.3)
 *   - function constructor?
 *   - function invocation (20.9.11.2.4) - bad_function_call if !*this, otherwise exceptions from wrapped callable
 *   - basic_string - throws out_of_range if pos > str.size()
 *   - conditional_variable_any [thread.condition.condvarany] Throws: bad_alloc or system_error when an exception is required (30.2.2).
 *     - void wait(unique_lock<mutex>& lock, Predicate pred); transfers exceptions from Predicate to wait
 *   - resource_unavailable_try_again — if some non-memory resource limitation prevents initialization.
 *   - operation_not_permitted — if the thread does not have the privilege to perform the operation.
 *   - std::thread::detach - std::system_error if joinable() == false or an error occurs.
 *   - lambdas and similar
 *   - quick_exit
 *   - std::throw_with_nested
 *   - std::rethrow_with_nested
 *   - others, as found by searching for "throws" in the standard
 * - Improve the accuracy of the matching of ExceptionTypes to HandlerTypes:
 *   - Do not match ambiguous public base class
 *   - Add extra qualification conversions (pointer to member etc.)
 *   - Standard pointer conversions should not include conversions to "pointers to private or protected or ambiguous classes".
 *   - Convert handlers of type "array of T" or "function returning T" to "pointer to T" or "pointer to function returning T"
 *   - We can ignore incomplete types, an abstract class types, or an rvalue reference types
 */

/**
 * An type which may be used as an exception type in the program.
 *
 * This consists of:
 *  - All the statically thrown "exception types" in the program.
 *  - Exception types derived from `std::exception`
 *  - Exception types derived from the third-party base exception types.
 */
class ExceptionType extends Type {
  ExceptionType() {
    this = any(DirectThrowExpr dte).getExceptionType()
    or
    exists(Class baseClass |
      baseClass instanceof StdException
      or
      baseClass instanceof ThirdPartyBaseExceptionType
    |
      // Derived from a known exception base class
      this.(Class).getABaseClass*() = baseClass
    )
  }

  /** Gets a printable name for this exception. */
  string getExceptionName() {
    if this instanceof Class
    then result = this.(Class).getQualifiedName()
    else result = this.getName()
  }
}

/** A `ThrowExpr` which does not rethrow the current exception. */
class DirectThrowExpr extends ThrowExpr {
  DirectThrowExpr() { not this instanceof ReThrowExpr }

  /** Gets the static exception type thrown. */
  Type getExceptionType() {
    /*
     * The exception type of a direct throw is determined by removing top-level cv-qualifiers from the static
     * type.
     *
     * Note: this deliberately uses ThrowExpr.getType() instead of ThrowExpr.getExpr().getType(), because EDG
     * appears to populate that with the necessary transformations that occur as a result of copy construction.
     * In addition, getExpr().getType() in some cases returns a void type when the expression is a `ConstructorCall`.
     */

    result = this.getType().getUnspecifiedType()
  }
}

/** Gets the nearest parent try statement for the given statement. */
TryStmt getNearestTry(Stmt s) {
  if s.getParent() instanceof TryStmt
  then result = s.getParent()
  else result = getNearestTry(s.getParent())
}

/** Gets the nearest parent catch block for the given statement. */
CatchBlock getNearestCatch(Stmt s) {
  if s.getParent() instanceof CatchBlock
  then result = s.getParent()
  else result = getNearestCatch(s.getParent())
}

/**
 * A type declared for a parameter in a catch handler, or as a function dynamic exception specification.
 */
class HandlerType extends Type {
  HandlerType() {
    this = any(CatchBlock cb).getParameter().getType()
    or
    this = any(Function f).getAThrownType()
  }

  /** Gets a printable name for the handled type. */
  string getHandledTypeName() {
    if this instanceof Class
    then result = this.(Class).getQualifiedName()
    else result = this.getName()
  }
}

/** A list of `ExceptionType`s in the program that might be handled by this `CatchBlock`. */
predicate isCaught(CatchBlock cb, ExceptionType e) {
  // Any ExceptionType is possible here
  cb instanceof CatchAnyBlock
  or
  e = getAHandledExceptionType(cb.getParameter().getType())
}

/**
 * Gets an `ExceptionType` which could be handled by a catch block with the given `HandlerType`.
 *
 * See `[except.handle]`.
 */
ExceptionType getAHandledExceptionType(HandlerType handlerType) {
  // First simplify the HandlerType, to make the matching easier
  exists(Type t | t = simplifyHandlerType(handlerType) |
    // [except.handle]/3.1
    result = t
    or
    // [except.handle]/3.2
    result.(Class).getABaseClass+() = t
    or
    // [except.handle]/3.3.1 - `result` can be converted to `t` by standard pointer conversions
    // [conv.ptr]/2 - `result` can be converted to `t` because `t` is void
    result instanceof PointerType and
    t.(PointerType).getBaseType().stripTopLevelSpecifiers() instanceof VoidType
    or
    // [conv.ptr]/2 - `result` can be converted to `t` because `t` points to a base class of the type `result` points to
    result.(PointerType).getBaseType().stripTopLevelSpecifiers().(Class).getABaseClass*() =
      t.(PointerType).getBaseType().stripTopLevelSpecifiers()
    or
    // [except.handle]/3.3.2 - `result` can be converted to `t` by qualification conversion (`[conv.qual]`)
    exists(Type ePointsTo, SpecifiedType tPointsTo |
      ePointsTo = result.(PointerType).getBaseType() and
      tPointsTo = t.(PointerType).getBaseType()
    |
      // [conv.qual] - if result and t are both pointer types, and t is more qualified than result
      forall(Specifier specifier | specifier = ePointsTo.getASpecifier() |
        tPointsTo.hasSpecifier(specifier.getName())
      )
    )
    or
    // [except.handle]/3.4
    result instanceof NullPointerType and
    (t instanceof PointerType or t instanceof PointerToMemberType)
  )
}

/** Gets the simplified `Type` which will be used to determine exception types handled by this `HandlerType`. */
Type simplifyHandlerType(HandlerType handlerType) {
  if result instanceof PointerType
  then
    result = handlerType.stripTopLevelSpecifiers()
    or
    exists(ReferenceType rt |
      rt = handlerType.stripTopLevelSpecifiers() and
      // ignoring top-level cv-qualifiers for the base type
      result = rt.getBaseType().stripTopLevelSpecifiers() and
      not rt.getBaseType().isVolatile()
    )
  else (
    result = handlerType.stripTopLevelSpecifiers()
    or
    // ignoring top-level cv-qualifiers for the base type
    result =
      handlerType.stripTopLevelSpecifiers().(ReferenceType).getBaseType().stripTopLevelSpecifiers()
  )
}

/** And expression which can directly or indirectly throw an exception. */
abstract class ThrowingExpr extends Expr {
  /**
   * Get a `ExceptionType` thrown by this `ThrowingExpr`.
   */
  abstract ExceptionType getAnExceptionType();
}

/** The `CatchBlock` `cb` catches the `ExceptionType` `et` thrown by the `ThrowingExpr` `te`. */
cached
predicate catches(CatchBlock cb, ThrowingExpr te, ExceptionType et) {
  exists(int tryDepth, int catchDepth |
    cb = candidates(te, tryDepth, catchDepth) and
    et = te.getAnExceptionType() and
    isCaught(cb, et) and
    not exists(CatchBlock closerCb, int closerTryDepth, int closerCatchDepth |
      closerCb = candidates(te, closerTryDepth, closerCatchDepth) and
      isCaught(closerCb, et)
    |
      closerTryDepth < tryDepth
      or
      closerTryDepth = tryDepth and closerCatchDepth < catchDepth
    )
  )
}

/**
 * Get a candidate catch block for each `ThrowingExpr` in a function.
 */
CatchBlock candidates(ThrowingExpr te, int tryDepth, int catchDepth) {
  exists(TryStmt ts |
    // Throwing expression is contained within the body of the try statement
    te.getEnclosingStmt().getParentStmt*() = ts.getStmt() and
    tryDepth =
      count(TryStmt nested |
        // Contained within the body of the nested try statement
        te.getEnclosingStmt().getParentStmt+() = nested.getStmt() and
        // Try statement is contained within the body of the outer statement
        nested.getParentStmt+() = ts.getStmt()
      ) and
    result = ts.getCatchClause(catchDepth)
  )
}

/**
 * Gets a possible exception type that may be thrown by the function, from the given `throwingExpr`.
 */
ExceptionType getAFunctionThrownType(Function f, ThrowingExpr throwingExpr) {
  result = throwingExpr.getAnExceptionType() and
  throwingExpr.getEnclosingFunction() = f and
  // Report any thrown exception for which there does not exist at least one catch block which would catch it
  not exists(CatchBlock cb |
    isCaught(cb, result) and
    cb = candidates(throwingExpr, _, _)
  )
}

module ExceptionPathGraph {
  /**
   * A function for which we want path information.
   */
  abstract class ExceptionThrowingFunction extends Function {
    /** Holds if there is exception flow between the source and function node, for the given exception type. */
    predicate hasExceptionFlow(
      ExceptionFlowNode exceptionSource, ExceptionFlowNode functionNode, ExceptionType et
    ) {
      functionNode.asFunction() = this and
      edges+(exceptionSource, functionNode) and
      exceptionSource.getExceptionType() = et and
      exceptionSource.asThrowingExpr() instanceof OriginThrowingExpr
    }
  }

  /** A ThrowingExpr for which we want path information */
  abstract class ExceptionThrowingExpr extends Expr {
    ExceptionThrowingExpr() { this instanceof ThrowingExpr }

    ThrowingExpr asThrowingExpr() { result = this }

    /** Holds if there is exception flow between the source and function node, for the given exception type. */
    predicate hasExceptionFlow(
      ExceptionFlowNode exceptionSource, ExceptionFlowNode throwingNode, ExceptionType et
    ) {
      throwingNode.asThrowingExpr() = this and
      edges+(exceptionSource, throwingNode) and
      exceptionSource.getExceptionType() = et and
      exceptionSource.asThrowingExpr() instanceof OriginThrowingExpr
    }

    predicate hasExceptionFlowReflexive(
      ExceptionFlowNode exceptionSource, ExceptionFlowNode throwingNode, ExceptionType et
    ) {
      throwingNode.asThrowingExpr() = this and
      edges*(exceptionSource, throwingNode) and
      exceptionSource.getExceptionType() = et and
      exceptionSource.asThrowingExpr() instanceof OriginThrowingExpr
    }
  }

  /**
   * Internal predicate for calculating relevant nodes in the exception graph.
   */
  private predicate reachable(Function f, ExceptionType et) {
    // Base case - starting from a ExprThrowingFunction
    f instanceof ExceptionThrowingFunction and et = getAFunctionThrownType(f, _)
    or
    // Base case - starting from an ExceptionThrowingExpr
    exists(ExceptionThrowingExpr throwingExpr, ExceptionType exceptionType |
      exceptionType = throwingExpr.asThrowingExpr().getAnExceptionType() and
      f = throwingExpr.(FunctionCallThrowingExpr).getTarget()
    )
    or
    // Recursive case
    exists(Function reached, FunctionCallThrowingExpr fcte |
      reachable(reached, et) and
      et = getAFunctionThrownType(reached, fcte) and
      f = fcte.getTarget()
    )
  }

  /**
   * A node class for reporting relevant paths in the program.
   */
  newtype TExceptionFlowNode =
    ThrowingExprNode(ThrowingExpr te, ExceptionType exceptionType) {
      // A ThrowingExpr which directly causes a function to exit with an exception
      exists(Function f |
        reachable(f, exceptionType) and
        exceptionType = getAFunctionThrownType(f, te)
      )
      or
      // A ThrowingExpr which is caught and rethrown in the function
      exists(TExceptionFlowNode rethrown, ReThrowExprThrowingExpr re |
        // Catch block is already in the node graph
        rethrown = RethrowCatchBlockNode(_, re, exceptionType) and
        re.rethrows(_, exceptionType, te)
      )
      or
      // An exception we explicitly want to model
      te instanceof ExceptionThrowingExpr and
      exceptionType = te.getAnExceptionType()
    } or
    FunctionNode(Function f, ExceptionType exceptionType) { reachable(f, exceptionType) } or
    /** A catch block which catches a relevant exception type, and contains a rethrow expression. */
    RethrowCatchBlockNode(CatchBlock cb, ReThrowExprThrowingExpr re, ExceptionType exceptionType) {
      exists(TExceptionFlowNode ten |
        // Re-throw exception is already in the node graph
        ten = ThrowingExprNode(re, exceptionType) and
        re.rethrows(cb, exceptionType, _)
      )
    }

  class ExceptionFlowNode extends TExceptionFlowNode {
    Function asFunction() { this = FunctionNode(result, _) }

    ThrowingExpr asThrowingExpr() { this = ThrowingExprNode(result, _) }

    CatchBlock asCatchBlock() { this = RethrowCatchBlockNode(result, _, _) }

    ExceptionType getExceptionType() {
      this = FunctionNode(_, result)
      or
      this = ThrowingExprNode(_, result)
      or
      this = RethrowCatchBlockNode(_, _, result)
    }

    Location getLocation() {
      result = asFunction().getLocation()
      or
      result = asThrowingExpr().getLocation()
      or
      result = asCatchBlock().getLocation()
    }

    string toString() {
      result = asFunction().toString() + " [" + getExceptionType() + "]"
      or
      result = asThrowingExpr().toString() + " [" + getExceptionType() + "]"
      or
      result = asCatchBlock().toString() + " [" + getExceptionType() + "]"
    }
  }

  query predicate edges(ExceptionFlowNode e1, ExceptionFlowNode e2) {
    // Throwing expressions to functions which exit with that exception
    exists(Function f, ExceptionType exceptionType, ThrowingExpr throwingExpr |
      exceptionType = getAFunctionThrownType(f, throwingExpr) and
      e1 = ThrowingExprNode(throwingExpr, exceptionType) and
      e2 = FunctionNode(f, exceptionType)
    )
    or
    // Functions which exit with exceptions to ThrowingExprs which call them
    exists(FunctionCallThrowingExpr throwingExpr, ExceptionType exceptionType |
      exceptionType = throwingExpr.getAnExceptionType() and
      e1 = FunctionNode(throwingExpr.getTarget(), exceptionType) and
      e2 = ThrowingExprNode(throwingExpr, exceptionType)
    )
    or
    // Catch blocks to re-throwing expressions
    exists(
      CatchBlock catchBlock, ReThrowExprThrowingExpr rethrowingExpr, ExceptionType exceptionType
    |
      exceptionType = rethrowingExpr.getAnExceptionType() and
      e1 = RethrowCatchBlockNode(catchBlock, rethrowingExpr, exceptionType) and
      e2 = ThrowingExprNode(rethrowingExpr, exceptionType)
    )
    or
    // Throwing expressions to catch blocks
    exists(
      CatchBlock catchBlock, ThrowingExpr originalThrow, ReThrowExprThrowingExpr rethrowingExpr,
      ExceptionType exceptionType
    |
      exceptionType = originalThrow.getAnExceptionType() and
      e1 = ThrowingExprNode(originalThrow, exceptionType) and
      e2 = RethrowCatchBlockNode(catchBlock, rethrowingExpr, exceptionType) and
      rethrowingExpr.rethrows(catchBlock, exceptionType, originalThrow)
    )
  }
}
