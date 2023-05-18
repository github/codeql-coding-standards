import cpp
import semmle.code.cpp.security.OutputWrite
import codingstandards.cpp.standardlibrary.FileStreams

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

/**
 * A `FileStreamFunctionCall` operation is considered a log operation for Coding Standards purposes.
 */
class FileStreamLogging extends LoggingOperation {
  FileStreamLogging() { this instanceof FileStreamFunctionCall }

  override Expr getALoggedExpr() { result = this.(FileStreamFunctionCall).getAnArgument() }

  Expr getFStream() { result = this.(FileStreamFunctionCall).getQualifier() }
}

/** A call which looks like `printf`. */
class PrintfLikeCall extends LoggingOperation, Call {
  PrintfLikeCall() { getTarget().getName().toLowerCase().matches("%printf%") }

  override Expr getALoggedExpr() { result = getAnArgument() }
}

/**
 * In a wrapper `Function`, all accesses of all `Parameters`
 * are in located in logging or stream calls
 */
class LoggerOrStreamWrapperFunction extends Function {
  LoggerOrStreamWrapperFunction() {
    forall(VariableAccess va |
      exists(Parameter p | p.getFunction() = this and va = p.getAnAccess())
    |
      any(LoggingOperation logOp).getALoggedExpr().getAChild*() = va
    )
  }
}
