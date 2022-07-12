/**
 * Provides a library which models functions which act as entry points or encapsulating function.
 */

import cpp

/** A function which represents the entry point into a specific thread of execution in the program. */
abstract class MainLikeFunction extends Function { }

/** A function which encapsulates third-party libraries or separate components. */
abstract class EncapsulatingFunction extends Function { }

/** A `main` function with an int return type. */
class MainFunction extends MainLikeFunction {
  MainFunction() {
    hasGlobalName("main") and
    getType() instanceof IntType
  }
}

/**
 * A "task main" function.
 */
abstract class TaskMainFunction extends MainLikeFunction { }
