/**
 * A module for reasoning about unused functions.
 *
 * This module provides an `UnusedFunction` class which represents functions which are not called
 * from one of the specified entry points.
 *
 * By default entry points include main-like functions and global and namespace variable
 * initializers. Further entry points can be specified by extending `EntryPoint`, and implementing
 * the `getAReachableFunction()` predicate.
 */

import cpp
import codingstandards.cpp.DynamicCallGraph
import codingstandards.cpp.EncapsulatingFunctions
import codingstandards.cpp.FunctionEquivalence
import codingstandards.cpp.Class

module UnusedFunctions {
  /**
   * Gets a call or access to `Function` by an expression.
   */
  Expr getACallOrAccess(Function f) {
    // Use the CallGraph library to deduce possible call targets for a function call
    //
    // Note: we do not consider whether this expression is reachable within the given function. For
    // the purpose of Coding Standards there are other queries that would flag unreachable
    // expressions.
    f = getTarget(result)
    or
    // Also consider the "static" target of the call to be used
    // This allows e.g. pure virtual functions to still be considered as used
    f = result.(FunctionCall).getTarget()
    or
    // A function access, technically not a call but sufficient for our purposes
    f = result.(FunctionAccess).getTarget()
    or
    // Declaring a lambda expression will be considered sufficient for the lambda to be used.
    // TODO Add issue for improving lambda tracking
    //      - We do see some lambda calls in the database, where it can be statically resolved
    //        so handle those
    f = result.(LambdaExpression).getLambdaFunction()
  }

  /**
   * Whether function `f2` is directly reachable from `f1`.
   */
  predicate reachable(Function f1, Function f2) {
    // The function directly calls or accesses the other function
    f1 = getACallOrAccess(f2).getEnclosingFunction()
    or
    // If a function instantiation is used, then the template itself is considered used
    f1.isConstructedFrom(f2)
    or
    // If a function template is used, then any instantiation of that function is considered used
    f2.isConstructedFrom(f1)
  }

  /**
   * A declaration that should be considered to be an entry point for the application.
   */
  abstract class EntryPoint extends Declaration {
    /** Gets a `Function` which is reachable from this entry point. */
    abstract Function getAReachableFunction();
  }

  /*
   * TODO Consider the following as potential entry points:
   *  - section attributes for shared library constructors and destructors
   *  - signal handlers
   *  - unit test entry points
   *  - functions with "used" and "unused" attributes
   *  - library entry points, for example:
   *  // #define __MM_DLL_EXPORT __declspec(dllexport)
   *  // #else
   *  // #define __MM_DLL_EXPORT __attribute__ ((visibility("default")))
   */

  private class MainLikeFunctionEntryPoint extends EntryPoint, MainLikeFunction {
    MainLikeFunctionEntryPoint() { this instanceof MainLikeFunction }

    override Function getAReachableFunction() { reachable*(this, result) }
  }

  private class GlobalOrNamespaceVariableEntryPoint extends EntryPoint, GlobalOrNamespaceVariable {
    override Function getAReachableFunction() {
      exists(Function f |
        getACallOrAccess(f) = this.getInitializer().getExpr().getAChild*() and
        reachable*(f, result)
      )
    }
  }

  /** A `Function` instance which is a candidate to be considered "used" or "unused". */
  class UsableFunction extends Function {
    UsableFunction() {
      // Is this an interesting non-prototype function instance?
      // (Prototype instances are not interesting, because we may not have full visibility on the
      // call graph).
      (
        // A defined function is a non-prototype
        hasDefinition()
        or
        // pure virtual functions (=0) are not considered to have definitions, but can be unused
        this instanceof PureVirtualFunction
        or
        // Include functions from uninstantiated templates. These will not be defined if they are
        // never instantiated, so we have specifically ask for them here.
        this.isFromUninstantiatedTemplate(_)
      ) and
      // The user is not responsible for compiler generated
      not isCompilerGenerated()
    }
  }

  /**
   * A `Function` which is not used from an `EntryPoint`.
   *
   * This class over-approximates "use", to avoid reporting false positives.
   */
  class UnusedFunction extends UsableFunction {
    UnusedFunction() {
      // This function, or an equivalent function, is not reachable from any entry point
      not exists(EntryPoint ep | getAnEquivalentFunction(this) = ep.getAReachableFunction()) and
      // and it is not a constexpr. Refer issue #646.
      // The usages of constexpr is not well tracked and hence
      // to avoid false positives, this is added. In case there is an improvement in
      // handling constexpr in CodeQL, we can consider removing it.
      not this.isConstexpr()
    }

    string getDeadCodeType() {
      if reachable(_, this)
      then result = "never called from a main function or entry point."
      else result = "never called."
    }
  }

  /** A `SpecialMemberFunction` which is an `UnusedFunction`. */
  class UnusedSplMemberFunction extends UnusedFunction, SpecialMemberFunction { }
}
