/** Provides a library modeling the cstdlib header. */

import cpp

/** The function `std::quick_exit`. */
class StdQuickExit extends Function {
  StdQuickExit() { this.hasGlobalOrStdName("quick_exit") }
}

/** The function `std::abort`. */
class StdAbort extends Function {
  StdAbort() { this.hasGlobalOrStdName("abort") }
}

/** The function `std::_Exit`. */
class Std_Exit extends Function {
  Std_Exit() { this.hasGlobalOrStdName("_Exit") }
}
