/**
 * @id cpp/autosar/library-functions-abort-exit-getenv-and-system-from-library-cstdlib-used
 * @name M18-0-3: The library functions abort, exit, getenv and system from library <cstdlib> shall not be used
 * @description Functions abort, exit, getenv, and system from <cstdlib shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m18-0-3
 *       correctness
 *       security
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isBannedCStdLibCall(FunctionCall fc) {
  fc.getTarget().hasGlobalOrStdName(["abort", "exit", "getenv", "system"])
}

from FunctionCall fc
where
  not isExcluded(fc,
    BannedFunctionsPackage::libraryFunctionsAbortExitGetenvAndSystemFromLibraryCstdlibUsedQuery()) and
  isBannedCStdLibCall(fc)
select fc, "Use of banned function " + fc.getTarget().getName() + "."
