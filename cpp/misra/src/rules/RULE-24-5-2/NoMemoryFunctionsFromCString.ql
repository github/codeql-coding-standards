/**
 * @id cpp/misra/no-memory-functions-from-c-string
 * @name RULE-24-5-2: The C++ Standard Library functions memcpy, memmove and memcmp from <cstring> shall not be used
 * @description Using memcpy, memmove or memcmp from <cstring> can result in undefined behavior due
 *              to overlapping memory, non-trivially copyable objects, or unequal comparison of
 *              logically equal objects.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-24-5-2
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.BannedFunctions

class BannedMemoryFunction extends Function {
  BannedMemoryFunction() { this.hasGlobalOrStdName(["memcpy", "memmove", "memcmp"]) }
}

from BannedFunctions<BannedMemoryFunction>::Use use
where not isExcluded(use, BannedAPIsPackage::noMemoryFunctionsFromCStringQuery())
select use, use.getAction() + " banned function '" + use.getFunctionName() + "' from <cstring>."
