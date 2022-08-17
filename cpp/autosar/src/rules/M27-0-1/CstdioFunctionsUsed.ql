/**
 * @id cpp/autosar/cstdio-functions-used
 * @name M27-0-1: The stream input/output library <cstdio> functions shall not be used
 * @description Streams and file I/O have a large number of unspecified, undefined, and
 *              implementation-defined behaviours associated with them.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m27-0-1
 *       maintainability
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from FunctionCall fc, Function f
where
  not isExcluded(fc, BannedLibrariesPackage::cstdioFunctionsUsedQuery()) and
  f = fc.getTarget() and
  f.hasGlobalOrStdName([
      "remove", "rename", "tmpfile", "tmpnam",
      // File access
      "fclose", "fflush", "fopen", "freopen", "setbuf", "setvbuf",
      // Formatted input/output
      "fprintf", "fscanf", "printf", "scanf", "snprintf", "sprintf", "sscanf", "vfprintf",
      "vfscanf", "vprintf", "vscanf", "vsnprintf", "vsprintf", "vsscanf",
      // Character input/output
      "fgetc", "fgets", "fputc", "fputs", "getc", "getchar", "gets", "putc", "putchar", "puts",
      "ungetc",
      // Direct input/output
      "fread", "fwrite",
      // File positioning
      "fgetpos", "fseek", "fsetpos", "ftell", "rewind",
      // Error handling
      "clearerr", "feof", "ferror", "perror"
    ])
select fc, "Use of <cstdio> function '" + f.getQualifiedName() + "'."
