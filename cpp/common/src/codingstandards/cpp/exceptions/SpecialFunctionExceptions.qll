/**
 * Provides a library for modeling exceptions which may be thrown by "special" functions such as
 * destructors, deallocator functions, move assignment, move constructor and swap functions.
 *
 * The library provides the `SpecialExceptionThrowingFunction` class, which represents all special
 * functions which throw exceptions. In addition, it provides the following classes:
 *
 *  - SpecialFunction - all destructors, deallocators, move assignment operators, move constructors, and swap functions
 *  - DestructorOrDeallocatorExceptionThrowingFunction - destructor and deallocator functions
 *  - MoveExceptionThrowingFunction - move assignment operators and move constructor functions
 *  - SwapExceptionThrowingFunction - swap functions
 *
 * These are all subclasses of `ExceptionThrowingFunction`, which can also provide a path-graph
 * which reports how the unhandled exception reached that function.
 */

import cpp
private import ExceptionFlow
private import codingstandards.cpp.Function
private import codingstandards.cpp.Swap
private import codingstandards.cpp.EncapsulatingFunctions
private import codingstandards.cpp.exceptions.ExceptionFlow

/** A special function. */
class SpecialFunction extends Function {
  string specialDescription;

  SpecialFunction() {
    this instanceof MoveAssignmentOperator and
    specialDescription = "move assignment operator"
    or
    this instanceof MoveConstructor and
    specialDescription = "move constructor"
    or
    this instanceof Destructor and
    specialDescription = "destructor"
    or
    this instanceof DeallocationFunction and
    specialDescription = "deallocation function"
    or
    this instanceof SwapFunction and
    specialDescription = "swap function"
  }

  string getSpecialDescription() { result = specialDescription }
}

/**
 * A function which isn't special by itself, but is used in a special context.
 *
 * For example, functions which are reachable from initializers of static or thread-local
 * variables can result in implementation-defined behavior if they throw exceptions.
 */
abstract class SpecialUseOfFunction extends Expr {
  abstract Function getFunction();

  abstract string getSpecialDescription(Locatable extra, string extraString);
}

class FunctionUsedInInitializer extends FunctionCall, SpecialUseOfFunction {
  Variable var;

  FunctionUsedInInitializer() {
    (var.isStatic() or var.isThreadLocal() or var.isTopLevel()) and
    exists(Expr initializer |
      var.getInitializer().getExpr() = initializer and
      getParent*() = initializer
    )
  }

  override Function getFunction() { result = this.getTarget() }

  override string getSpecialDescription(Locatable extra, string extraString) {
    result = "used to initialize variable $@" and
    extra = var and
    extraString = var.getName()
  }
}

class FunctionGivenToStdExitHandler extends FunctionAccess, SpecialUseOfFunction {
  Function exitHandler;
  FunctionCall exitHandlerCall;

  FunctionGivenToStdExitHandler() {
    exitHandler.hasGlobalOrStdName(["atexit", "at_quick_exit", "set_terminate"]) and
    exitHandlerCall.getTarget() = exitHandler and
    exitHandlerCall.getArgument(0) = this
  }

  override Function getFunction() { result = getTarget() }

  override string getSpecialDescription(Locatable extra, string extraString) {
    result = "$@" and
    extra = exitHandlerCall and
    extraString = "passed to the exit handler std::" + exitHandler.getName()
  }
}

class FunctionPassedToExternC extends FunctionAccessLikeExpr, SpecialUseOfFunction {
  Function cFunction;
  FunctionCall cFunctionCall;

  FunctionPassedToExternC() {
    cFunction.hasCLinkage() and
    cFunction = cFunctionCall.getTarget() and
    cFunctionCall.getAnArgument() = this
  }

  override Function getFunction() { result = this.(FunctionAccessLikeExpr).getFunction() }

  override string getSpecialDescription(Locatable extra, string extraString) {
    result = "$@ extern \"C\" function '" + cFunction.getName() + "'" and
    extra = cFunctionCall and
    extraString = "passed to"
  }
}

/** A special function which throws an exception. */
abstract class SpecialExceptionThrowingFunction extends ExceptionPathGraph::ExceptionThrowingFunction
{
  SpecialExceptionThrowingFunction() { exists(getAFunctionThrownType(this, _)) }

  /** Gets a description for this exception throwing. */
  abstract string getFunctionType();
}

/** A destructor or deallocator that throws an exception. */
class DestructorOrDeallocatorExceptionThrowingFunction extends SpecialExceptionThrowingFunction {
  string description;

  DestructorOrDeallocatorExceptionThrowingFunction() {
    this instanceof Destructor and description = "Destructor"
    or
    this instanceof DeallocationFunction and description = "Deallocation function"
  }

  override string getFunctionType() { result = description }
}

/** A move assignment operator or move constructor that throws an exception. */
class MoveExceptionThrowingFunction extends SpecialExceptionThrowingFunction {
  MoveExceptionThrowingFunction() {
    this instanceof MoveAssignmentOperator
    or
    this instanceof MoveConstructor
  }

  override string getFunctionType() { result = "Move function" }
}

/** A swap function that throws an exception. */
class SwapExceptionThrowingFunction extends SpecialExceptionThrowingFunction {
  SwapExceptionThrowingFunction() { this instanceof SwapFunction }

  override string getFunctionType() { result = "Swap function" }
}
