/**
 * Provides a library with a `problems` predicate for the following issue:
 * Streams and file I/O have a large number of unspecified, undefined, and
 * implementation-defined behaviours associated with them.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CstdioMacrosUsedSharedQuery extends Query { }

Query getQuery() { result instanceof CstdioMacrosUsedSharedQuery }

query predicate problems(MacroInvocation mi, string message) {
  not isExcluded(mi, getQuery()) and
  mi.getMacroName() in [
      "BUFSIZ", "EOF", "FILENAME_MAX", "FOPEN_MAX", "L_tmpnam", "TMP_MAX", "_IOFBF", "IOLBF",
      "_IONBF", "SEEK_CUR", "SEEK_END", "SEEK_SET"
    ] and
  message = "Use of <cstdio> macro '" + mi.getMacroName() + "'."
}
