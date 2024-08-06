/**
 * Provides a library with a `problems` predicate for the following issue:
 * Streams and file I/O have a large number of unspecified, undefined, and
 * implementation-defined behaviours associated with them.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CstdioFunctionsUsedSharedQuery extends Query { }

Query getQuery() { result instanceof CstdioFunctionsUsedSharedQuery }

query predicate problems(FunctionCall fc, string message) {
  exists(Function f |
    not isExcluded(fc, getQuery()) and
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
      ]) and
    message = "Use of <cstdio> function '" + f.getQualifiedName() + "'."
  )
}
