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
 * A test function from the GoogleTest infrastructure.
 *
 * Such functions can be treated as valid EntryPoint functions during analysis
 * of "called" or "unused" functions. It is not straightforward to identify
 * such functions, however, they have certain features that can be used for
 * identification. This can be refined based on experiments/real-world use.
 */
class GTestFunction extends MainLikeFunction {
  GTestFunction() {
    // A GoogleTest function is named "TestBody" and
    this.hasName("TestBody") and
    // is enclosed by a class that inherits from a base class
    this.getEnclosingAccessHolder() instanceof Class and
    exists(Class base |
      base = this.getEnclosingAccessHolder().(Class).getABaseClass() and
      (
        // called "Test" or
        exists(Class c | base.getABaseClass() = c and c.hasName("Test"))
        or
        // defined under a namespace called "testing" or
        exists(Namespace n | n = base.getNamespace() | n.hasName("testing"))
        or
        // is templatized by a parameter called "gtest_TypeParam_"
        exists(TemplateParameter tp |
          tp = base.getATemplateArgument() and
          tp.hasName("gtest_TypeParam_")
        )
      )
    )
  }
}

/**
 * A "task main" function.
 */
abstract class TaskMainFunction extends MainLikeFunction { }
