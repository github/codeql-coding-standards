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
      "ispunct", "isspace", "isupper", "isxdigit", "tolower", "toupper",
      "iswalnum", "iswalpha", "iswblank", "iswcntrl", "iswctype", "iswdigit", "iswgraph",
      "iswlower", "iswprint", "iswpunct", "iswspace", "iswupper", "iswxdigit", "towctrans",
      "towlower", "towupper", "wctrans", "wctype"
    ]) and
    not (
      this.hasGlobalOrStdName([
        "isalnum", "isalpha", "isblank", "iscntrl", "isdigit", "isgraph", "islower", "isprint",
        "ispunct", "isspace", "isupper", "isxdigit", "tolower", "toupper"
      ]) and
      this.getACallToThisFunction().(FunctionCall).getNumberOfArguments() = 2
    )
  }
}

from BannedFunctions<BannedCharacterHandlingFunction>::Use use
where
  not isExcluded(use, BannedAPIsPackage::characterHandlingFunctionRestrictionsQuery())
select use, use.getAction() + " banned character handling function '" + use.getFunctionName() + "' from <cctype> or <cwctype>."