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

ComparisonOperation getAValidComparison(string spec) {
  spec = "=0" and result.(EqualityOperation).getAnOperand().getValue() = "0"
  or
  spec = "=NULL" and result.(EqualityOperation).getAnOperand() instanceof NULL
  or
  spec = "=EOF" and result.(EqualityOperation).getAnOperand() = any(EOFInvocation i).getExpr()
  or
  spec = "=WEOF" and result.(EqualityOperation).getAnOperand() = any(WEOFInvocation i).getExpr()
  or
  spec = "=thrd_error" and
  result.(EqualityOperation).getAnOperand().(EnumConstantAccess).toString() = "thrd_error"
  or
  spec = "=thrd_nomem" and
  result.(EqualityOperation).getAnOperand().(EnumConstantAccess).toString() = "thrd_nomem"
  or
  spec = "=thrd_timedout" and
  result.(EqualityOperation).getAnOperand().(EnumConstantAccess).toString() = "thrd_timedout"
  or
  spec = "=thrd_busy" and
  result.(EqualityOperation).getAnOperand().(EnumConstantAccess).toString() = "thrd_busy"
  or
  spec = "=UINTMAX_MAX" and
  result.(EqualityOperation).getAnOperand() =
    any(MacroInvocation i | i.getMacroName() = "UINTMAX_MAX").getExpr()
  or
  spec = "=ULONG_MAX" and
  result.(EqualityOperation).getAnOperand() =
    any(MacroInvocation i | i.getMacroName() = "ULONG_MAX").getExpr()
  or
  spec = "=ULLONG_MAX" and
  result.(EqualityOperation).getAnOperand() =
    any(MacroInvocation i | i.getMacroName() = "ULLONG_MAX").getExpr()
  or
  spec = "=SIG_ERR" and
  result.(EqualityOperation).getAnOperand() =
    any(MacroInvocation i | i.getMacroName() = "SIG_ERR").getExpr()
  or
  spec = "=INTMAX_MAX" and
  result.(EqualityOperation).getAnOperand() =
    any(MacroInvocation i | i.getMacroName() = ["INTMAX_MAX", "INTMAX_MIN"]).getExpr()
  or
  spec = "=LONG_MAX" and
  result.(EqualityOperation).getAnOperand() =
    any(MacroInvocation i | i.getMacroName() = ["LONG_MAX", "LONG_MIN"]).getExpr()
  or
  spec = "=LLONG_MAX" and
  result.(EqualityOperation).getAnOperand() =
    any(MacroInvocation i | i.getMacroName() = ["LLONG_MAX", "LLONG_MIN"]).getExpr()
  or
  spec = "=-1" and
  result.(EqualityOperation).getAnOperand().(UnaryMinusExpr).getOperand().getValue() = "1"
  or
  spec = "=int" and
  result.(EqualityOperation).getAnOperand().getType() instanceof IntType
  or
  spec = "<0" and
  result.(RelationalOperation).getOperator() = ["<", ">="] and
  result.(RelationalOperation).getGreaterOperand().getValue() = "0"
  or
  spec = "<int" and
  result.(RelationalOperation).getOperator() = ["<", ">="] and
  result.(RelationalOperation).getLesserOperand().getType() instanceof IntType
}

/**
 * Calls whose return value must be checked
 * using an `errOperator` against `errValue`
 */
abstract class ExpectedErrReturn extends FunctionCall {
  ComparisonOperation errOperator;

  ComparisonOperation getErrOperator() { result = errOperator }
}

/**
 * Calls that must be checked agains `0`.
 *
 * example:
 * ```
 * if (strftime(b, 10, "", local) == 0) { ... }
 * ```
 */
class ExpectedErrReturnEqZero extends ExpectedErrReturn {
  ExpectedErrReturnEqZero() {
    this.getTarget()
        .hasName([
            "asctime_s", "at_quick_exit", "atexit", "ctime_s", "fgetpos", "fopen_s", "freopen_s",
            "fseek", "fsetpos", "mbsrtowcs_s", "mbstowcs_s", "raise", "remove", "rename", "setvbuf",
            "strerror_s", "strftime", "strtod", "strtof", "strtold", "timespec_get", "tmpfile_s",
            "tmpnam_s", "tss_get", "wcsftime", "wcsrtombs_s", "wcstod", "wcstof", "wcstold",
            "wcstombs_s", "wctrans", "wctype"
          ])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=0") }
}

/**
 * Calls that must be checked agains `NULL`.
 *
 * example:
 * ```
 * if (aligned_alloc(0, 0) == NULL) { ... }
 * ```
 */
class ExpectedErrReturnEqNull extends ExpectedErrReturn {
  ExpectedErrReturnEqNull() {
    this.getTarget()
        .hasName([
            "aligned_alloc", "bsearch_s", "bsearch", "calloc", "fgets", "fopen", "freopen",
            "getenv_s", "getenv", "gets_s", "gmtime_s", "gmtime", "localtime_s", "localtime",
            "malloc", "memchr", "realloc", "setlocale", "strchr", "strpbrk", "strrchr", "strstr",
            "strtok_s", "strtok", "tmpfile", "tmpnam", "wcschr", "wcspbrk", "wcsrchr", "wcsstr",
            "wcstok_s", "wcstok", "wmemchr"
          ])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=0") }
}

/**
 * Calls that must be checked agains `EOF` or `WEOF`.
 *
 * example:
 * ```
 * if (wctob(0) == EOF) { ... }
 * ```
 */
class ExpectedErrReturnEqEof extends ExpectedErrReturn {
  ExpectedErrReturnEqEof() {
    this.getTarget()
        .hasName([
            "fclose", "fflush", "fputs", "fputws", "fscanf_s", "fscanf", "fwscanf_s", "fwscanf",
            "scanf_s", "scanf", "sscanf_s", "sscanf", "swscanf_s", "swscanf", "ungetc", "vfscanf_s",
            "vfscanf", "vfwscanf_s", "vfwscanf", "vscanf_s", "vscanf", "vsscanf_s", "vsscanf",
            "vswscanf_s", "vswscanf", "vwscanf_s", "vwscanf", "wctob", "wscanf_s", "wscanf",
            "fgetc", "fputc", "getc", "getchar", "putc", "putchar", "puts"
          ])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=EOF") }
}

/**
 * Calls that must be checked agains`WEOF`.
 *
 * example:
 * ```
 * if (btowc(0) == WEOF) { ... }
 * ```
 */
class ExpectedErrReturnEqWeof extends ExpectedErrReturn {
  ExpectedErrReturnEqWeof() {
    this.getTarget()
        .hasName(["btowc", "fgetwc", "fputwc", "getwc", "getwchar", "putwc", "ungetwc", "putwchar"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=WEOF") }
}

/**
 * Calls that must be checked agains an enun constant.
 *
 * example:
 * ```
 * if (cnd_broadcast(&q) == thrd_error) { ... }
 * ```
 */
class ExpectedErrReturnEqEnumConstant_thrd_error extends ExpectedErrReturn {
  ExpectedErrReturnEqEnumConstant_thrd_error() {
    this.getTarget()
        .hasName([
            "cnd_broadcast", "cnd_init", "cnd_signal", "cnd_timedwait", "cnd_wait", "mtx_init",
            "mtx_lock", "mtx_timedlock", "mtx_trylock", "mtx_unlock", "thrd_create", "thrd_detach",
            "thrd_join", "tss_create", "tss_set"
          ])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=thrd_error") }
}

class ExpectedErrReturnEqEnumConstant_thrd_nomem extends ExpectedErrReturn {
  ExpectedErrReturnEqEnumConstant_thrd_nomem() {
    this.getTarget().hasName(["cnd_init", "thrd_create"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=thrd_nomem") }
}

class ExpectedErrReturnEqEnumConstant_thrd_timedout extends ExpectedErrReturn {
  ExpectedErrReturnEqEnumConstant_thrd_timedout() {
    this.getTarget().hasName(["cnd_timedwait", "mtx_timedlock"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=thrd_timedout") }
}

class ExpectedErrReturnEqEnumConstant_thrd_busy extends ExpectedErrReturn {
  ExpectedErrReturnEqEnumConstant_thrd_busy() { this.getTarget().hasName(["mtx_trylock"]) }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=thrd_busy") }
}

/**
 * Calls that must be checked agains a macro.
 *
 * example:
 * ```
 * if (strtoumax(str, &endptr, 0) == UINTMAX_MAX) { ... }
 * ```
 */
class ExpectedErrReturnEqMacroInvocation_UINTMAX_MAX extends ExpectedErrReturn {
  ExpectedErrReturnEqMacroInvocation_UINTMAX_MAX() {
    this.getTarget().hasName(["strtoumax", "wcstoumax"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=UINTMAX_MAX") }
}

class ExpectedErrReturnEqMacroInvocation_ULONG_MAX extends ExpectedErrReturn {
  ExpectedErrReturnEqMacroInvocation_ULONG_MAX() {
    this.getTarget().hasName(["strtoul", "wcstoul"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=ULONG_MAX") }
}

class ExpectedErrReturnEqMacroInvocation_ULLONG_MAX extends ExpectedErrReturn {
  ExpectedErrReturnEqMacroInvocation_ULLONG_MAX() {
    this.getTarget().hasName(["strtoull", "wcstoull"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=ULLONG_MAX") }
}

class ExpectedErrReturnEqMacroInvocation_SIG_ERR extends ExpectedErrReturn {
  ExpectedErrReturnEqMacroInvocation_SIG_ERR() { this.getTarget().hasName(["signal"]) }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=SIG_ERR") }
}

class ExpectedErrReturnEqMacroInvocation_INTMAX_MAX extends ExpectedErrReturn {
  ExpectedErrReturnEqMacroInvocation_INTMAX_MAX() {
    this.getTarget().hasName(["strtoimax", "wcstoimax"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=INTMAX_MAX") }
}

class ExpectedErrReturnEqMacroInvocation_LONG_MAX extends ExpectedErrReturn {
  ExpectedErrReturnEqMacroInvocation_LONG_MAX() { this.getTarget().hasName(["strtol", "wcstol"]) }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=LONG_MAX") }
}

class ExpectedErrReturnEqMacroInvocation_LLONG_MAX extends ExpectedErrReturn {
  ExpectedErrReturnEqMacroInvocation_LLONG_MAX() {
    this.getTarget().hasName(["strtoll", "wcstoll"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=LLONG_MAX") }
}

/**
 * Calls that must be checked agains `-1`.
 *
 * example:
 * ```
 * if (clock() == (clock_t)(-1)) { ... }
 * ```
 */
class ExpectedErrReturnEqMinusOne extends ExpectedErrReturn {
  ExpectedErrReturnEqMinusOne() {
    this.getTarget()
        .hasName([
            "c16rtomb", "c32rtomb", "clock", "ftell", "mbrtoc16", "mbrtoc32", "mbsrtowcs",
            "mbstowcs", "mktime", "time", "wcrtomb", "wcsrtombs", "wcstombs"
          ])
    or
    // functions that behave differently when the first argument is NULL
    not this.getArgument(0) instanceof NULL and
    this.getTarget().hasName(["mblen", "mbrlen", "mbrtowc", "mbtowc", "wctomb_s", "wctomb"])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=-1") }
}

/**
 * Calls that must be checked agains an integer value.
 *
 * example:
 * ```
 * if (fread(b, sizeof *b, SIZE, fp) == SIZE) { ... }
 * ```
 */
class ExpectedErrReturnEqInt extends ExpectedErrReturn {
  ExpectedErrReturnEqInt() { this.getTarget().hasName(["fread", "fwrite"]) }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("=int") }
}

/**
 * Calls that must be compared to `0`.
 *
 * example:
 * ```
 * if (snprintf(NULL, 0, fmt, sqrt(2) >= 0) { ... }
 * ```
 */
class ExpectedErrReturnLtZero extends ExpectedErrReturn {
  ExpectedErrReturnLtZero() {
    this.getTarget()
        .hasName([
            "fprintf_s", "fprintf", "fwprintf_s", "fwprintf", "printf_s", "snprintf_s", "snprintf",
            "sprintf_s", "sprintf", "swprintf_s", "swprintf", "thrd_sleep", "vfprintf_s",
            "vfprintf", "vfwprintf_s", "vfwprintf", "vprintf_s", "vsnprintf_s", "vsnprintf",
            "vsprintf_s", "vsprintf", "vswprintf_s", "vswprintf", "vwprintf_s", "wprintf_s",
            "printf", "vprintf", "wprintf", "vwprintf"
          ])
  }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("<0") }
}

/**
 * Calls that must be compared to an integer value.
 *
 * example:
 * ```
 * if (strxfrm(out, in, sizeof out) >= 10) { ... }
 * ```
 */
class ExpectedErrReturnLtInt extends ExpectedErrReturn {
  ExpectedErrReturnLtInt() { this.getTarget().hasName(["strxfrm", "wcsxfrm"]) }

  override ComparisonOperation getErrOperator() { result = getAValidComparison("<int") }
}

/**
 * Calls that do not return error values.
 *
 * example:
 * ```
 * if (kill_dependency(a) == a) { ... }
 * ```
 */
class ExpectedErrReturnNA extends ExpectedErrReturn {
  ExpectedErrReturnNA() {
    this.getTarget()
        .hasName([
            "kill_dependency", "memcpy", "wmemcpy", "memmove", "wmemmove", "strcpy", "wcscpy",
            "strncpy", "wcsncpy", "strcat", "wcscat", "strncat", "wcsncat", "memset", "wmemset"
          ])
  }
}

/**
 * Calls not checked using ferror() && feof()
 *
 * example:
 * ```
 * do {
 *   getchar(); // COMPLIANT
 * } while ((!feof(stdin) && !ferror(stdin)));
 * ```
 */
class MissingFerrorFeof extends FunctionCall {
  MissingFerrorFeof() {
    this.getTarget().hasName(["fgetc", "fgetwc", "getc", "getchar"])
    implies
    missingFeofFerrorChecks(this)
  }
}

/**
 * Calls not checked using ferror()
 *
 * example:
 * ```
 * do {
 *   fputc(0, f);
 * } while (!ferror(f));
 * ```
 */
class MissingFerror extends FunctionCall {
  MissingFerror() {
    this.getTarget().hasName(["fputc", "putc"])
    implies
    this.getEnclosingFunction() = ferrorNotchecked(this)
  }
}

/**
 *  ERR33-C-EX1: calls that are not cast to `void`
 *
 * ```
 * (void)putchar('C');
 * ```
 */
class MissingVoidCast extends FunctionCall {
  MissingVoidCast() {
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
    not sameFileSource(result.(FerrorCall), write)
  )
}

from ExpectedErrReturn err
where
  not isExcluded(err, Contracts5Package::detectAndHandleStandardLibraryErrorsQuery()) and
  // Function calls were the return value is not checked
  not exists(ComparisonOperation op |
    DataFlow::localExprFlow(err, op.getAnOperand()) and
    op = err.getErrOperator() and
    // special case for function `realloc`:
    // the returned pointer should not be invalidated
    // `p = realloc(p, n);` // NON_COMPLIANT
    // `if (p == NULL) { ... }`
    not (
      err.getTarget().hasName("realloc") and
      op.getAnOperand().(VariableAccess).getTarget() =
        err.getArgument(0).(VariableAccess).getTarget()
    )
  ) and
  // Functions that could potentially be checked differently
  err instanceof MissingFerrorFeof and
  err instanceof MissingFerror and
  err instanceof MissingVoidCast
select err, "Missing error detection for the call to function `" + err.getTarget() + "`."
