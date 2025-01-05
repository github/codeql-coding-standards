/**
 * Provides a library which includes a `problems` predicate for reporting unchecked error values.
 */

import cpp
import codingstandards.cpp.Customizations
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.Guards
import codingstandards.cpp.Exclusions

abstract class FunctionErroneousReturnValueNotTestedSharedQuery extends Query { }

Query getQuery() { result instanceof FunctionErroneousReturnValueNotTestedSharedQuery }

query predicate problems(FunctionCall fc, string message) {
  not isExcluded(fc, getQuery()) and
  fc.getTarget()
      .hasGlobalOrStdName([
          // fcntl.h
          "open", "openat", "fcntl", "creat",
          // locale.h
          "setlocale",
          // stdlib.h
          "system", "getenv", "getenv_s",
          // signal.h
          "signal", "raise",
          // setjmp.h
          "setjmp",
          // stdio.h
          "fopen", "fopen_s", "freopen", "freopen_s", "fclose", "fcloseall", "fflush", "setvbuf",
          "fgetc", "getc", "fgets", "fputc", "getchar", "gets", "gets_s", "putchar", "puts",
          "ungetc", "scanf", "fscanf", "sscanf", "scanf_s", "fscanf_s", "sscanf_s", "vscanf",
          "vfscanf", "vsscanf", "vscanf_s", "vfscanf_s", "vsscanf_s", "printf", "fprintf",
          "sprintf", "snprintf", "printf_s", "fprintf_s", "sprintf_s", "snprintf_s", "vprintf",
          "vfprintf", "vsprintf", "vsnprintf", "vprintf_s", "vfprintf_s", "vsprintf_s",
          "vsnprintf_s", "ftell", "fgetpos", "fseek", "fsetpos", "remove", "rename", "tmpfile",
          "tmpfile_s", "tmpnam", "tmpnam_s",
          // string.h
          "strcpy_s", "strncpy_s", "strcat_s", "strncat_s", "memset_s", "memcpy_s", "memmove_s",
          "strerror_s",
          // threads.h
          "thrd_create", "thrd_sleep", "thrd_detach", "thrd_join", "mtx_init", "mtx_lock",
          "mtx_timedlock", "mtx_trylock", "mtx_unlock", "cnd_init", "cnd_signal", "cnd_broadcast",
          "cnd_wait", "cnd_timedwait", "tss_create", "tss_get", "tss_set",
          // time.h
          "time", "clock", "timespec_get", "asctime_s", "ctime_s", "gmtime", "gmtime_s",
          "localtime", "localtime_s",
          // unistd.h
          "write", "read", "close", "unlink",
          // wchar.h
          "fgetwc", "getwc", "fgetws", "fputwc", "putwc", "fputws", "getwchar", "putwchar",
          "ungetwc", "wscanf", "fwscanf", "swscanf", "wscanf_s", "fwscanf_s", "swscanf_s",
          "vwscanf", "vfwscanf", "vswscanf", "vwscanf_s", "vfwscanf_s", "vswscanf_s", "wprintf",
          "fwprintf", "swprintf", "wprintf_s", "fwprintf_s", "swprintf_s", "snwprintf_s",
          "vwprintf", "vfwprintf", "vswprintf", "vwprintf_s", "vfwprintf_s", "vswprintf_s",
          "vsnwprintf_s"
        ]) and
  not exists(GuardCondition gc |
    DataFlow::localFlow(DataFlow::exprNode(fc), DataFlow::exprNode(gc.getAChild*()))
  ) and
  message = "Return value from " + fc.getTarget().getName() + " is not tested for errors."
}
