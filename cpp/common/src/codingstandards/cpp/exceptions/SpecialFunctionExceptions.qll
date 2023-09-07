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
private import codingstandards.cpp.Swap
private import codingstandards.cpp.EncapsulatingFunctions
private import codingstandards.cpp.exceptions.ExceptionFlow

/** A special function. */
class SpecialFunction extends Function {
  SpecialFunction() {
    this instanceof MoveAssignmentOperator
    or
    this instanceof MoveConstructor
    or
    this instanceof Destructor
    or
    this instanceof DeallocationFunction
    or
    this instanceof SwapFunction
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
