/**
 * Provides a library which includes a `problems` predicate for reporting abrupt termination of the
 * program using `std::terminate`, `std::quick_exit`, `std::abort` or `std::exit`.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.standardlibrary.CStdLib
import codingstandards.cpp.standardlibrary.Exceptions

abstract class ExplicitAbruptTerminationSharedQuery extends Query { }

Query getQuery() { result instanceof ExplicitAbruptTerminationSharedQuery }

class ExplicitTerminationCall extends FunctionCall {
  ExplicitTerminationCall() {
    getTarget() instanceof StdTerminate
    or
    getTarget() instanceof StdQuickExit
    or
    getTarget() instanceof StdAbort
    or
    getTarget() instanceof Std_Exit
  }
}

query predicate problems(ExplicitTerminationCall explicitTermination, string message) {
  not isExcluded(explicitTermination, getQuery()) and
  message = "Explicit termination of the program"
}
