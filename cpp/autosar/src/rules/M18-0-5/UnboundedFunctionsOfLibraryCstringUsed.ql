/**
 * @id cpp/autosar/unbounded-functions-of-library-cstring-used
 * @name M18-0-5: The unbounded functions of library <cstring> shall not be used
 * @description The unbounded functions of the <cstring> library shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m18-0-5
 *       security
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isBannedCStringFunctionCall(FunctionCall fc) {
  fc.getTarget()
      .hasGlobalOrStdName([
          "strcpy", "strncpy", "strcat", "strncat", "strcmp", "strcoll", "strncmp", "strxfrm",
          "strchr", "strcspn", "strpbrk", "strrchr", "strspn", "strstr", "strtok", "strlen"
        ])
}

from FunctionCall fc
where
  not isExcluded(fc, BannedFunctionsPackage::unboundedFunctionsOfLibraryCstringUsedQuery()) and
  isBannedCStringFunctionCall(fc)
select fc, "Use of un-bounded function " + fc.getTarget().getName() + "."
