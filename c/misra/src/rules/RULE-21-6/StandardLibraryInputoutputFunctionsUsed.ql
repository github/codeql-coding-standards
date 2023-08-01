/**
 * @id c/misra/standard-library-inputoutput-functions-used
 * @name RULE-21-6: The Standard Library input/output functions shall not be used
 * @description The use of the Standard Library input/output functions may result in undefined
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6
 *       security
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

private string stdInputOutput() {
  result =
    [
      "fread", "fwrite", "fgetc", "getc", "fgets", "fputc", "putc", "fputs", "getchar", "gets",
      "gets_s", "putchar", "puts", "ungetc", "scanf", "fscanf", "sscanf", "scanf_s", "fscanf_s",
      "sscanf_s", "vscanf", "vfscanf", "vsscanf", "vscanf_s", "vfscanf_s", "vsscanf_s", "printf",
      "fprintf", "sprintf", "snprintf", "printf_s", "fprintf_s", "sprintf_s", "snprintf_s",
      "vprintf", "vfprintf", "vsprintf", "vsnprintf", "vprintf_s", "vfprintf_s", "vsprintf_s",
      "vsnprintf_s",
    ]
}

private string wcharInputOutput() {
  result =
    [
      "fgetwc", "getwc", "fgetsws", "fputwc", "putwc", "fputws", "getwchar", "putwchar", "ungetwc",
      "wscanf", "fwscanf", "swscanf", "wscanf_s", "fwscanf_s", "swscanf_s", "vwscanf", "vfwscanf",
      "vswscanf", "vwscanf_s", "vfwscanf_s", "vswscanf_s", "wprintf", "fwprintf", "swprintf",
      "wprintf_s", "fwprintf_s", "swprintf_s", "snwprintf_s", "vwprintf", "vfwprintf", "vswprintf",
      "vwprintf_s", "vfwprintf_s", "vswprintf_s", "vsnwprintf_s",
    ]
}

from FunctionCall fc, Function f
where
  not isExcluded(fc, BannedPackage::standardLibraryInputoutputFunctionsUsedQuery()) and
  fc.getTarget() = f and
  (
    f.getName() = stdInputOutput() and
    f.getFile().getBaseName() = "stdio.h"
    or
    f.getName() = wcharInputOutput() and
    f.getFile().getBaseName() = "wchar.h"
  )
select fc, "Call to banned function " + f.getName() + "."
