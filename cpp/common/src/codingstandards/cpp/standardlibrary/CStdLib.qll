/** Provides a library modeling the cstdlib header. */

import cpp

/** The function `std::quick_exit`. */
class StdQuickExit extends Function {
  StdQuickExit() { hasQualifiedName("std", "quick_exit") }
}

/** The function `std::abort`. */
class StdAbort extends Function {
  StdAbort() { hasQualifiedName("std", "abort") }
}

/** The function `std::_Exit`. */
class Std_Exit extends Function {
  Std_Exit() { hasQualifiedName("std", "_Exit") }
}
