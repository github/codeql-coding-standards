/**
 * @id cpp/misra/poorly-formed-identifier
 * @name RULE-5-10-1: User-defined identifiers shall have an appropriate form
 * @description Identifiers shall not conflict with keywords, reserved names, or otherwise be poorly
 *              formed.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-10-1
 *       scope/single-translation-unit
 *       readability
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Identifiers

predicate isReservedName(string name) {
  name in [
      "defined", "final", "override", "clock_t", "div_t", "FILE", "fpos_t", "lconv", "ldiv_t",
      "mbstate_t", "ptrdiff_t", "sig_atomic_t", "size_t", "time_t", "tm", "va_list", "wctrans_t",
      "wctype_t", "wint_t"
    ]
}

bindingset[s]
predicate hasDoubleUnderscore(string s) { s.matches("%\\_\\_%") }

bindingset[s]
predicate startsWithUnderscore(string s) { s.matches("\\_%") }

predicate isReservedLiteralSuffix(Function f, IdentifierIntroduction intro) {
  // `operator"" _km` is reserved while `operator ""_km` is not. We don't have adequate information
  // from the extractor to distinguish this, however, we can use offset information to detect
  // `operator "" _km` as a best effort guess.
  f = intro.getElement().(FunctionDeclarationEntry).getFunction() and
  f.getName().matches("operator%\"\"%") and
  startsWithUnderscore(intro.getIdent()) and
  exists(Location loc, int reservedLength, int actualLength | loc = intro.getLocation() |
    loc.getStartLine() = loc.getEndLine() and
    reservedLength = ("operator \"\" " + intro).length() and
    actualLength = loc.getEndColumn() - loc.getStartColumn() + 1 and
    reservedLength = actualLength
  )
}

predicate isReservedNamespace(Namespace ns) {
  ns.getName().regexpMatch("std\\d+") or ns.getName() = "posix"
}

bindingset[s]
predicate containsLowercase(string s) { s.regexpMatch(".*[a-z].*") }

from IdentifierIntroduction intro, string ident, string message
where
  not isExcluded(intro.getElement(), Naming2Package::poorlyFormedIdentifierQuery()) and
  ident = intro.unescapeUnicode() and
  (
    exists(int idx |
      intro.hasNonUax44Codepoint(idx) and
      message =
        "Identifier '" + ident + "' has non-UAX44 codepoint at index " + idx + ": '" +
          ident.codePointAt(idx) + "'." and
      not ident.charAt(idx) = "_"
    )
    or
    exists(int idx, string noOrMaybe |
      intro.hasNonNfcNormalizedCodepoint(idx, noOrMaybe) and
      message =
        "Identifier '" + ident + "' has non-NFC normalized codepoint at index " + idx +
          " with NFC_QC value '" + noOrMaybe + "'."
    )
    or
    intro.isFromMacro() and
    not ident.regexpMatch("^[a-zA-Z0-9_]+$") and
    message = "Identifier '" + ident + "' contains invalid characters."
    or
    intro.isFromMacro() and
    containsLowercase(ident) and
    message = "Identifier '" + ident + "' contains lowercase characters."
    or
    hasDoubleUnderscore(ident) and
    message = "Identifier '" + ident + "' contains double underscores." and
    not (intro.isFromMacro() and ident = "__VA_ARGS__")
    or
    startsWithUnderscore(ident) and
    not intro.isLiteralSuffix() and
    message = "Identifier '" + ident + "' starts with underscore." and
    not (intro.isFromMacro() and ident = "__VA_ARGS__")
    or
    not startsWithUnderscore(ident) and
    intro.isLiteralSuffix() and
    message = "User-defined literal suffix '" + ident + "' does not start with underscore."
    or
    isReservedName(ident) and
    message = "Identifier '" + ident + "' is a reserved name."
    or
    isReservedNamespace(intro.getNamespace()) and
    message = "Identifier '" + ident + "' is defined in reserved namespace."
    or
    exists(Function func | func = intro.getElement().(FunctionDeclarationEntry).getFunction() |
      isReservedLiteralSuffix(func, intro) and
      message =
        "User-defined literal suffix '" + ident +
          "' is reserved due to leading underscore and space."
    )
  )
select intro, message
