import cpp
import semmle.code.cpp.security.OutputWrite

/**
 * A operation which may perform logging.
 */
abstract class LoggingOperation extends Expr {
  /** Gets the highest-level expression which may be logged. */
  abstract Expr getALoggedExpr();
}

/**
 * An `OutputWrite` operation is considered a log operation for Coding Standards purposes.
 */
class OutputWriteLogging extends LoggingOperation, OutputWrite {
  override Expr getALoggedExpr() { result = getASource() }
}

/** A call which looks like `printf`. */
class PrintfLikeCall extends LoggingOperation, Call {
  PrintfLikeCall() { getTarget().getName().toLowerCase().matches("%printf%") }

  override Expr getALoggedExpr() { result = getAnArgument() }
}
