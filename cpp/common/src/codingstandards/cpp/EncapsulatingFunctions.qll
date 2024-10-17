/**
 * Provides a library which models functions which act as entry points or encapsulating function.
 */

import cpp
import codingstandards.cpp.Class

/** A function which represents the entry point into a specific thread of execution in the program. */
abstract class MainLikeFunction extends Function { }

/** A function which encapsulates third-party libraries or separate components. */
abstract class EncapsulatingFunction extends Function { }

/** A `main` function with an int return type. */
class MainFunction extends MainLikeFunction {
  MainFunction() {
    hasGlobalName("main") and
    getType().resolveTypedefs() instanceof IntType
  }
}

/**
 * A test function from the GoogleTest infrastructure.
 *
 * Such functions can be treated as valid EntryPoint functions during analysis
 * of "called" or "unused" functions. It is not straightforward to identify
 * such functions, however, they have certain features that can be used for
 * identification. This can be refined based on experiments/real-world use.
 */
class GoogleTestFunction extends MainLikeFunction {
  GoogleTestFunction() {
    // A GoogleTest function is named "TestBody" and
    (
      this.hasName("TestBody") or
      this instanceof SpecialMemberFunction
    ) and
    // it's parent class inherits a base class
    exists(Class base |
      base = this.getEnclosingAccessHolder+().(Class).getABaseClass+() and
      (
        // with a name "Test" inside a namespace called "testing"
        base.hasName("Test") and
        base.getNamespace().hasName("testing")
        or
        // or at a location in a file called gtest.h (or gtest-internal.h,
        // gtest-typed-test.h etc).
        base.getDefinitionLocation().getFile().getBaseName().regexpMatch("gtest*.h")
      )
    )
  }
}

/**
 * A "task main" function.
 */
abstract class TaskMainFunction extends MainLikeFunction { }
