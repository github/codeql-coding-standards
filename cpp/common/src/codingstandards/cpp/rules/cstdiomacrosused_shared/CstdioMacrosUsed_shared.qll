/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class CstdioMacrosUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof CstdioMacrosUsed_sharedSharedQuery }

query predicate problems(MacroInvocation mi, string message) {
  not isExcluded(mi, getQuery()) and
  mi.getMacroName() in [
      "BUFSIZ", "EOF", "FILENAME_MAX", "FOPEN_MAX", "L_tmpnam", "TMP_MAX", "_IOFBF", "IOLBF",
      "_IONBF", "SEEK_CUR", "SEEK_END", "SEEK_SET"
    ] and
  message = "Use of <cstdio> macro '" + mi.getMacroName() + "'."
}
