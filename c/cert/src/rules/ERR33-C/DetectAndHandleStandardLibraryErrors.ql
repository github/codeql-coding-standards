/**
 * @id c/cert/detect-and-handle-standard-library-errors
 * @name ERR33-C: Detect and handle standard library errors
 * @description Detect and handle standard library errors. Undetected failures can lead to
 *              unexpected or undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err33-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.commons.NULL
import codingstandards.cpp.ReadErrorsAndEOF

/**
 * Classifies error returning function calls based on the
 * type and value of the required checked
 */
abstract class ExpectedErrReturn extends FunctionCall {
  Expr errValue;
  ComparisonOperation errOperator;

  Expr getErrValue() { result = errValue }

  ComparisonOperation getErrOperator() { result = errOperator }
}

class ExpectedErrReturnEqZero extends ExpectedErrReturn {
  ExpectedErrReturnEqZero() {
    errOperator instanceof EqualityOperation and
    errValue.(Literal).getValue() = "0" and
    this.getTarget()
        .hasName([
            "asctime_s", "at_quick_exit", "atexit", "ctime_s", "fgetpos", "fopen_s", "freopen_s",
            "fseek", "fsetpos", "mbsrtowcs_s", "mbstowcs_s", "raise", "remove", "rename", "setvbuf",
            "strerror_s", "strftime", "strtod", "strtof", "strtold", "timespec_get", "tmpfile_s",
            "tmpnam_s", "tss_get", "wcsftime", "wcsrtombs_s", "wcstod", "wcstof", "wcstold",
            "wcstombs_s", "wctrans", "wctype"
          ])
  }
}

class ExpectedErrReturnEqNull extends ExpectedErrReturn {
  ExpectedErrReturnEqNull() {
    errOperator instanceof EqualityOperation and
    errValue instanceof NULL and
    this.getTarget()
        .hasName([
            "aligned_alloc", "bsearch_s", "bsearch", "calloc", "fgets", "fopen", "freopen",
            "getenv_s", "getenv", "gets_s", "gmtime_s", "gmtime", "localtime_s", "localtime",
            "malloc", "memchr", "realloc", "setlocale", "strchr", "strpbrk", "strrchr", "strstr",
            "strtok_s", "strtok", "tmpfile", "tmpnam", "wcschr", "wcspbrk", "wcsrchr", "wcsstr",
            "wcstok_s", "wcstok", "wmemchr"
          ])
  }
}

class ExpectedErrReturnEqEofWeof extends ExpectedErrReturn {
  ExpectedErrReturnEqEofWeof() {
    errOperator instanceof EqualityOperation and
    (
      errValue = any(EOFInvocation i).getExpr() and
      this.getTarget()
          .hasName([
              "fclose", "fflush", "fputs", "fputws", "fscanf_s", "fscanf", "fwscanf_s", "fwscanf",
              "scanf_s", "scanf", "sscanf_s", "sscanf", "swscanf_s", "swscanf", "ungetc",
              "vfscanf_s", "vfscanf", "vfwscanf_s", "vfwscanf", "vscanf_s", "vscanf", "vsscanf_s",
              "vsscanf", "vswscanf_s", "vswscanf", "vwscanf_s", "vwscanf", "wctob", "wscanf_s",
              "wscanf", "fgetc", "fputc", "getc", "getchar", "putc", "putchar", "puts"
            ])
      or
      errValue = any(WEOFInvocation i).getExpr() and
      this.getTarget()
          .hasName([
              "btowc", "fgetwc", "fputwc", "getwc", "getwchar", "putwc", "ungetwc", "putwchar"
            ])
    )
  }
}

class ExpectedErrReturnEqEnumConstant extends ExpectedErrReturn {
  ExpectedErrReturnEqEnumConstant() {
    errOperator instanceof EqualityOperation and
    (
      errValue = any(EnumConstantAccess i | i.toString() = "thrd_error") and
      this.getTarget()
          .hasName([
              "cnd_broadcast", "cnd_init", "cnd_signal", "cnd_timedwait", "cnd_wait", "mtx_init",
              "mtx_lock", "mtx_timedlock", "mtx_trylock", "mtx_unlock", "thrd_create",
              "thrd_detach", "thrd_join", "tss_create", "tss_set"
            ])
      or
      errValue = any(EnumConstantAccess i | i.toString() = "thrd_nomem") and
      this.getTarget().hasName(["cnd_init", "thrd_create"])
      or
      errValue = any(EnumConstantAccess i | i.toString() = "thrd_timedout") and
      this.getTarget().hasName(["cnd_timedwait", "mtx_timedlock"])
      or
      errValue = any(EnumConstantAccess i | i.toString() = "thrd_busy") and
      this.getTarget().hasName(["mtx_trylock"])
    )
  }
}

class ExpectedErrReturnEqMacroInvocation extends ExpectedErrReturn {
  ExpectedErrReturnEqMacroInvocation() {
    errOperator instanceof EqualityOperation and
    (
      errValue = any(MacroInvocation i | i.getMacroName() = "UINTMAX_MAX").getExpr() and
      this.getTarget().hasName(["strtoumax", "wcstoumax"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = "ULONG_MAX").getExpr() and
      this.getTarget().hasName(["strtoul", "wcstoul"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = "ULLONG_MAX").getExpr() and
      this.getTarget().hasName(["strtoull", "wcstoull"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = "SIG_ERR").getExpr() and
      this.getTarget().hasName(["signal"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = ["INTMAX_MAX", "INTMAX_MIN"]).getExpr() and
      this.getTarget().hasName(["strtoimax", "wcstoimax"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = ["LONG_MAX", "LONG_MIN"]).getExpr() and
      this.getTarget().hasName(["strtol", "wcstol"])
      or
      errValue = any(MacroInvocation i | i.getMacroName() = ["LLONG_MAX", "LLONG_MIN"]).getExpr() and
      this.getTarget().hasName(["strtoll", "wcstoll"])
    )
  }
}

class ExpectedErrReturnEqMinusOne extends ExpectedErrReturn {
  ExpectedErrReturnEqMinusOne() {
    errOperator instanceof EqualityOperation and
    (
      errValue.(UnaryMinusExpr).getOperand().(Literal).getValue() = "1" and
      this.getTarget()
          .hasName([
              "c16rtomb", "c32rtomb", "clock", "ftell", "mbrtoc16", "mbrtoc32", "mbsrtowcs",
              "mbstowcs", "mktime", "time", "wcrtomb", "wcsrtombs", "wcstombs"
            ])
      or
      // functions that behave differently when the first argument is NULL
      errValue.(UnaryMinusExpr).getOperand().(Literal).getValue() = "1" and
      not this.getArgument(0) instanceof NULL and
      this.getTarget().hasName(["mblen", "mbrlen", "mbrtowc", "mbtowc", "wctomb_s", "wctomb"])
    )
  }
}

class ExpectedErrReturnEqInt extends ExpectedErrReturn {
  ExpectedErrReturnEqInt() {
    errOperator instanceof EqualityOperation and
    errValue.getType() instanceof IntType and
    this.getTarget().hasName(["fread", "fwrite"])
  }
}

class ExpectedErrReturnLtZero extends ExpectedErrReturn {
  ExpectedErrReturnLtZero() {
    errOperator.getOperator() = ["<", ">="] and
    errValue.(Literal).getValue() = "0" and
    this.getTarget()
        .hasName([
            "fprintf_s", "fprintf", "fwprintf_s", "fwprintf", "printf_s", "snprintf_s", "snprintf",
            "sprintf_s", "sprintf", "swprintf_s", "swprintf", "thrd_sleep", "vfprintf_s",
            "vfprintf", "vfwprintf_s", "vfwprintf", "vprintf_s", "vsnprintf_s", "vsnprintf",
            "vsprintf_s", "vsprintf", "vswprintf_s", "vswprintf", "vwprintf_s", "wprintf_s",
            "printf", "vprintf", "wprintf", "vwprintf"
          ])
  }
}

class ExpectedErrReturnLtInt extends ExpectedErrReturn {
  ExpectedErrReturnLtInt() {
    errOperator.getOperator() = ["<", ">="] and
    errValue.getType() instanceof IntType and
    this.getTarget().hasName(["strxfrm", "wcsxfrm"])
  }
}

class ExpectedErrReturnNA extends ExpectedErrReturn {
  ExpectedErrReturnNA() {
    errOperator.getOperator() = ["<", ">="] and
    errValue = any(Expr e) and
    this.getTarget()
        .hasName([
            "kill_dependency", "memcpy", "wmemcpy", "memmove", "wmemmove", "strcpy", "wcscpy",
            "strncpy", "wcsncpy", "strcat", "wcscat", "strncat", "wcsncat", "memset", "wmemset"
          ])
  }
}

/**
 *  calls that can be verified using ferror() && feof()
 */
class FerrorFeofException extends FunctionCall {
  FerrorFeofException() {
    this.getTarget().hasName(["fgetc", "fgetwc", "getc", "getchar"])
    implies
    missingFeofFerrorChecks(this)
  }
}

/**
 *  calls that can be verified using ferror()
 */
class FerrorException extends FunctionCall {
  FerrorException() {
    this.getTarget().hasName(["fputc", "putc"])
    implies
    this.getEnclosingFunction() = ferrorNotchecked(this)
  }
}

/**
 *  ERR33-C-EX1: calls that must not be verified if cast to `void`
 */
class VoidCastException extends FunctionCall {
  VoidCastException() {
    this.getTarget()
        .hasName([
            "putchar", "putwchar", "puts", "printf", "vprintf", "wprintf", "vwprintf",
            "kill_dependency", "memcpy", "wmemcpy", "memmove", "wmemmove", "strcpy", "wcscpy",
            "strncpy", "wcsncpy", "strcat", "wcscat", "strncat", "wcsncat", "memset", "wmemset"
          ])
    implies
    not this.getExplicitlyConverted() instanceof VoidConversion
  }
}

/**
 * CFG search:
 * Nodes following a file write before a call to `ferror` is performed
 */
ControlFlowNode ferrorNotchecked(FileWriteFunctionCall write) {
  result = write
  or
  exists(ControlFlowNode mid |
    mid = ferrorNotchecked(write) and
    //do not traverse the short-circuited CFG edge
    not isShortCircuitedEdge(mid, result) and
    result = mid.getASuccessor() and
    //Stop recursion on call to ferror on the correct file
    not accessSameTarget(result.(FerrorCall).getArgument(0), write.getFileExpr())
  )
}

from ExpectedErrReturn err
where
  not isExcluded(err, Contracts5Package::detectAndHandleStandardLibraryErrorsQuery()) and
  // calls that must be verified using the return value
  not exists(ComparisonOperation op |
    DataFlow::localExprFlow(err, op.getAnOperand()) and
    op = err.getErrOperator() and
    op.getAnOperand() = err.getErrValue() and
    // special case for function `realloc` where the returned pointer
    // should not be invalidated
    not (
      err.getTarget().hasName("realloc") and
      op.getAnOperand().(VariableAccess).getTarget() =
        err.getArgument(0).(VariableAccess).getTarget()
    )
  ) and
  // ERR33-C-EX1: calls for which it is acceptable
  // to ignore the return value
  err instanceof FerrorFeofException and
  err instanceof FerrorException and
  err instanceof VoidCastException
select err, "Missing error detection for the call to function `" + err.getTarget() + "`."
