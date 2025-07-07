/**
 * @id cpp/misra/unsafe-string-handling-functions
 * @name RULE-21-2-2: The string handling functions from <cstring>, <cstdlib>, <cwchar> and <cinttypes> shall not be used
 * @description Using string handling functions from <cstring>, <cstdlib>, <cwchar> and <cinttypes>
 *              headers may result in buffer overflows or unreliable error detection through errno.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-2-2
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.BannedFunctions

class StringFunction extends Function {
  StringFunction() {
    this.hasGlobalName([
        "strcat", "strchr", "strcmp", "strcoll", "strcpy", "strcspn", "strerror", "strlen",
        "strncat", "strncmp", "strncpy", "strpbrk", "strrchr", "strspn", "strstr", "strtok",
        "strxfrm", "strtol", "strtoll", "strtoul", "strtoull", "strtod", "strtof", "strtold",
        "fgetwc", "fputwc", "wcstol", "wcstoll", "wcstoul", "wcstoull", "wcstod", "wcstof",
        "wcstold", "strtoumax", "strtoimax", "wcstoumax", "wcstoimax"
      ])
  }
}

from BannedFunctions<StringFunction>::Use use
where not isExcluded(use, BannedAPIsPackage::unsafeStringHandlingFunctionsQuery())
select use, use.getAction() + " banned string handling function '" + use.getFunctionName() + "'."
