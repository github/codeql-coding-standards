/**
 * @id cpp/misra/character-handling-function-restrictions
 * @name RULE-24-5-1: The character handling functions from <cctype> and <cwctype> shall not be used
 * @description Using character classification and case mapping functions from <cctype> and
 *              <cwctype> causes undefined behavior when arguments are not representable as unsigned
 *              char or not equal to EOF.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-24-5-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.BannedFunctions

class BannedCharacterHandlingFunction extends Function {
  BannedCharacterHandlingFunction() {
    this.hasGlobalOrStdName([
        "isalnum", "isalpha", "isblank", "iscntrl", "isdigit", "isgraph", "islower", "isprint",
        "ispunct", "isspace", "isupper", "isxdigit", "tolower", "toupper", "iswalnum", "iswalpha",
        "iswblank", "iswcntrl", "iswctype", "iswdigit", "iswgraph", "iswlower", "iswprint",
        "iswpunct", "iswspace", "iswupper", "iswxdigit", "towctrans", "towlower", "towupper",
        "wctrans", "wctype"
      ]) and
    // Exclude the functions which pass a reference to a std::locale as the second parameter
    not this.getParameter(1)
        .getType()
        .getUnspecifiedType()
        .(ReferenceType)
        .getBaseType()
        .(UserType)
        .hasQualifiedName("std", "locale")
  }
}

from BannedFunctions<BannedCharacterHandlingFunction>::Use use
where not isExcluded(use, BannedAPIsPackage::characterHandlingFunctionRestrictionsQuery())
select use,
  use.getAction() + " banned character handling function '" + use.getFunctionName() +
    "' from <cctype> or <cwctype>."
