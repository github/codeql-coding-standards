/** Provides the reserved-macro detector shared by MISRA C guideline identities. */

import cpp
import codingstandards.cpp.Naming

/** Gets a reserved name defined or undefined by `directive`. */
string getReservedMacroName(PreprocessorDirective directive) {
  (
    directive.(Macro).hasName(result)
    or
    directive.(PreprocessorUndef).getName() = result
  ) and
  (
    Naming::Cpp14::hasStandardLibraryMacroName(result)
    or
    Naming::Cpp14::hasStandardLibraryObjectName(result)
    or
    result.regexpMatch("_.*")
    or
    result = "defined"
  )
}
