/** Provides a library for modeling swap functions. */

import cpp

/** A function which is intended to swap two values. */
abstract class SwapFunction extends Function { }

/** A member function which swaps the parameter with the qualifier. */
class MemberSwapFunction extends SwapFunction, MemberFunction {
  MemberSwapFunction() {
    getNumberOfParameters() = 1 and
    getDeclaringType() =
      getParameter(0).getType().stripTopLevelSpecifiers().(ReferenceType).getBaseType() and
    getName().toLowerCase() = "swap"
  }
}

/** A function which swaps parameter 0 and parameter 1. */
class AdjacentSwapFunction extends SwapFunction {
  AdjacentSwapFunction() {
    getNumberOfParameters() = 2 and
    getParameter(0).getType() = getParameter(1).getType() and
    getName().toLowerCase() = "swap"
  }
}
