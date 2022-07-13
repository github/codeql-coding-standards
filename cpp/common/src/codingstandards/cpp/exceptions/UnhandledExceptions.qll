/**
 * Provides a library for modeling exceptions which may be unhandled in the program.
 *
 * The library provides the `UnhandledExceptionFunction` class, which represents entry point functions
 * in the program with uncaught exceptions. As it is a subclass of `ExceptionThrowingFunction`, it can
 * also provide a path-graph which reports how the unhandled exception reached that function.
 */

import cpp
private import ExceptionFlow
private import codingstandards.cpp.EncapsulatingFunctions

/**
 * An `ExceptionThrowingFunction` which exits with an exception which will then be unhandled by the program.
 */
class UnhandledExceptionFunction extends ExceptionPathGraph::ExceptionThrowingFunction {
  UnhandledExceptionFunction() {
    this instanceof MainLikeFunction and
    exists(getAFunctionThrownType(this, _))
  }
}
