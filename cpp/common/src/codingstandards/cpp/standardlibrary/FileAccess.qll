/**
 * A module for modeling classes and functions related to file streams in the C Standard Library.
 *
 * It also models various C file operations, including:
 *  - Calls to open and close functions
 *  - Calls to file positioning functions
 *  - Calls to read and write functions
 *  - Calls that access files implicitly (e.g. getchar with stdin)
 *  - Calls that use in-band errors (e.g. EOF)
 */

import semmle.code.cpp.pointsto.PointsTo

predicate opened(FunctionCall fc) {
  fopenCall(fc)
  or
  exists(Function f | f = fc.getTarget() | f.hasGlobalName("freopen"))
}

/** Holds if there exists a call to a function that might close the file specified by `e`. */
predicate closed(Expr e) {
  fcloseCall(_, e) or
  exists(ExprCall c |
    // cautiously assume that any ExprCall could be a call to fclose.
    c.getAnArgument() = e
  )
}

/** An expression for which there exists a function call that might close it. */
class ClosedExpr extends PointsToExpr {
  ClosedExpr() { closed(this) }

  override predicate interesting() { closed(this) }
}

/**
 * Holds if `fc` is a call to a function that opens a file that might be closed. For example:
 * ```
 * FILE* f = fopen("file.txt", "r");
 * ...
 * fclose(f);
 * ```
 */
predicate fopenCallMayBeClosed(FunctionCall fc) { opened(fc) and anythingPointsTo(fc) }

/**
 * The C/C++ `wint_t` type.
 */
class Wint_t extends Type {
  Wint_t() {
    this.getUnderlyingType() instanceof IntegralType and
    this.hasName("wint_t")
  }

  override string getAPrimaryQlClass() { result = "Wint_t" }
}

/**
 * A standard function call that opens a file
 */
class FOpenCall extends FunctionCall {
  FOpenCall() {
    this.getTarget().hasGlobalName(["fopen", "fdopen", "fopen_s", "freopen", "freopen_s", "open"])
  }

  /** The expression corresponding to the accessed file */
  Expr getFilenameExpr() {
    this.getTarget().hasGlobalName("open") and result = this.getArgument(0)
    or
    result = this.getArgument(getNumberOfArguments() - 2)
  }

  Expr getMode() {
    this.getTarget().hasGlobalName("open") and result = this.getArgument(1)
    or
    result = this.getArgument(getNumberOfArguments() - 1)
  }

  // make predicate
  predicate isReadMode() { this.getMode().getValue() = ["r", "r+", "w+", "a+"] }

  predicate isWriteMode() { this.getMode().getValue() = ["w", "a", "r+", "w+", "a+"] }

  predicate isReadOnlyMode() {
    this.isReadMode() and not this.isWriteMode()
    or
    exists(MacroInvocation mi |
      mi.getMacroName() = "O_RDONLY" and
      (
        this.getMode() = mi.getExpr()
        or
        this.getMode().(BitwiseOrExpr).getAnOperand*() = mi.getExpr()
      )
    )
  }

  predicate isReadWriteMode() { this.isReadMode() and this.isWriteMode() }
}

abstract class FileAccess extends FunctionCall {
  abstract Expr getFileExpr();
}

pragma[inline]
predicate sameFileSource(FileAccess a, FileAccess b) {
  exists(Variable c |
    c.getAnAccess() = a.getFileExpr() and
    c.getAnAccess() = b.getFileExpr()
  )
}

/** A function call that accesses files implicitly */
class ImplicitFileAccess extends FileAccess {
  string fileName;

  ImplicitFileAccess() {
    fileName = "stdin" and
    this.getTarget().hasGlobalName(["getchar", "getwchar", "scanf", "scanf_s"])
    or
    fileName = "stdout" and
    this.getTarget().hasGlobalName(["printf", "printf_s", "puts", "putchar", "putwchar"])
    or
    fileName = "stderr" and this.getTarget().hasGlobalName("perror")
  }

  /** The expression corresponding to the accessed file */
  override Expr getFileExpr() {
    result = any(MacroInvocation mi | mi.getMacroName() = fileName).getExpr() or
    fileName = result.findRootCause().(Macro).getName()
  }
}

/**
 * A function call that accesses a file and might return an in-band
 * error indicator (e.g. EOF)
 */
class InBandErrorReadFunctionCall extends FileAccess {
  InBandErrorReadFunctionCall() {
    this.getTarget().hasGlobalName(["getchar", "getwchar"]) or
    this.getTarget().hasGlobalName(["fgetc", "getc", "gets", "gets_s", "fgetwc", "getwc"])
  }

  /** The expression corresponding to the accessed file */
  override Expr getFileExpr() {
    if this instanceof ImplicitFileAccess
    then result = this.(ImplicitFileAccess).getFileExpr()
    else result = [this.getArgument(0), this.getArgument(0).(AddressOfExpr).getAnOperand()]
  }
}

/**
 * A function call that reads from a file
 */
class FileReadFunctionCall extends FileAccess {
  int filePos;

  FileReadFunctionCall() {
    this.getTarget().hasGlobalName(["getchar", "getwchar"]) and filePos = -1
    or
    this.getTarget()
        .hasGlobalName(["getc", "getwc", "fgetc", "fgetwc", "gets", "gets_s", "fscanf", "fscanf_s"]) and
    filePos = 0
    or
    this.getTarget().hasGlobalName(["fgets", "fgetws", "getline", "getwline"]) and filePos = 2
    or
    this.getTarget().hasGlobalName(["fread", "getdelim", "getwdelim"]) and filePos = 3
  }

  /** The expression corresponding to the accessed file */
  override Expr getFileExpr() {
    if this instanceof ImplicitFileAccess
    then result = this.(ImplicitFileAccess).getFileExpr()
    else
      result = [this.getArgument(filePos), this.getArgument(filePos).(AddressOfExpr).getAnOperand()]
  }
}

/**
 * A function call that writes to a file
 */
class FileWriteFunctionCall extends FileAccess {
  int filePos;

  FileWriteFunctionCall() {
    filePos = -1 and
    this.getTarget().hasGlobalName(["printf", "printf_s", "puts", "putchar", "putwchar", "perror"])
    or
    filePos = 0 and
    this.getTarget().hasGlobalName(["fprintf", "fprintf_s"])
    or
    filePos = 1 and
    this.getTarget()
        .hasGlobalName(["fputc", "putc", "fputs", "putwc", "fputwc", "fputws", "ungetwc", "ungetc"])
    or
    filePos = 3 and this.getTarget().hasGlobalName(["fwrite"])
  }

  /** The expression corresponding to the accessed file */
  override Expr getFileExpr() {
    if this instanceof ImplicitFileAccess
    then result = this.(ImplicitFileAccess).getFileExpr()
    else
      result = [this.getArgument(filePos), this.getArgument(filePos).(AddressOfExpr).getAnOperand()]
  }
}

/**
 * A function call that closes a file
 */
class FileCloseFunctionCall extends FileAccess {
  FileCloseFunctionCall() { this.getTarget().hasGlobalName("fclose") }

  /** The expression corresponding to the accessed file */
  override VariableAccess getFileExpr() {
    result = [this.getArgument(0), this.getArgument(0).(AddressOfExpr).getAnOperand()]
  }
}

/**
 * A file positioning function call that
 */
class FilePositioningFunctionCall extends FileAccess {
  FilePositioningFunctionCall() {
    this.getTarget().hasGlobalName(["fflush", "fseek", "fsetpos", "rewind"])
  }

  /** The expression corresponding to the accessed file */
  override Expr getFileExpr() {
    result = [this.getArgument(0), this.getArgument(0).(AddressOfExpr).getAnOperand()]
  }
}
