/**
 * A module for reasoning about the dynamic call graph.
 *
 * This module provides a `getTarget(Call c)` API which considers how a call target may be resolved
 * dynamically at runtime. In particular, it considers:
 *  - For virtual functions, which particular override is called based on the inferred type of the
 *    receiver.
 *  - For functions without definition targets, identifying whether there is an appropriate defined
 *    target in the database that is assumed to be dynamically linked.
 */

import cpp
private import semmle.code.cpp.dispatch.VirtualDispatchPrototype
private import FunctionEquivalence

/**
 * Gets a possible target for the `Call`, using the name and parameter matching if we did not associate
 * this call with a specific definition at link or compile time, and performing simple virtual
 * dispatch resolution.
 */
Function getTarget(Call c) {
  result = getTarget1(c) or
  result = getTarget2(c) or
  result = getTarget3(c)
}

/**
 * Gets a possible definition for the undefined function by matching the undefined function name
 * and parameter arity with a defined function.
 *
 * This is useful for identifying call to target dependencies across libraries, where the libraries
 * are never statically linked together.
 */
Function getAPossibleDefinition(Function undefinedFunction) {
  not undefinedFunction.hasDefinition() and
  result = getAnEquivalentFunction(undefinedFunction) and
  result.hasDefinition()
}

/**
 * Helper predicate for `getTarget`, that computes possible targets of a `Call`.
 *
 * If there is at least one defined target after performing some simple virtual dispatch
 * resolution, then the result is all the defined targets.
 */
private Function getTarget1(Call c) {
  result = VirtualDispatch::getAViableTarget(c) and
  result.hasDefinition()
}

/**
 * Helper predicate for `getTarget`, that computes possible targets of a `Call`.
 *
 * If we can use the heuristic matching of functions to find definitions for some of the viable
 * targets, return those.
 */
private Function getTarget2(Call c) {
  not exists(getTarget1(c)) and
  result = getAPossibleDefinition(VirtualDispatch::getAViableTarget(c))
}

/**
 * Helper predicate for `getTarget`, that computes possible targets of a `Call`.
 *
 * Otherwise, the result is the undefined `Function` instances.
 */
private Function getTarget3(Call c) {
  not exists(getTarget1(c)) and
  not exists(getTarget2(c)) and
  result = VirtualDispatch::getAViableTarget(c)
}
