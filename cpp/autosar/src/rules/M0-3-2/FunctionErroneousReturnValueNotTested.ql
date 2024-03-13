/**
 * @id cpp/autosar/function-erroneous-return-value-not-tested
 * @name M0-3-2: If a function generates error information, then that error information shall be tested
 * @description A function (whether it is part of the standard library, a third party library or a
 *              user defined function) may provide some means of indicating the occurrence of an
 *              error. This may be via a global error flag, a parametric error flag, a special
 *              return value or some other means. Whenever such a mechanism is provided by a
 *              function the calling program shall check for the indication of an error as soon as
 *              the function returns.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m0-3-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.Guards

from FunctionCall fc
where
  not isExcluded(fc, ExpressionsPackage::functionErroneousReturnValueNotTestedQuery()) and
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
  forall(GuardCondition gc |
    not DataFlow::localFlow(DataFlow::exprNode(fc), DataFlow::exprNode(gc.getAChild*()))
  )
select fc, "Return value is not tested for errors."
