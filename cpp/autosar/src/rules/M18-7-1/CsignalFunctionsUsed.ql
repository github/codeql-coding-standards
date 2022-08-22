/**
 * @id cpp/autosar/csignal-functions-used
 * @name M18-7-1: The signal-handling functions of <csignal> shall not be used
 * @description Signal handling contains implementation-defined and undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m18-7-1
 *       maintainability
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from FunctionCall fc, Function f
where
  not isExcluded(fc, BannedLibrariesPackage::csignalFunctionsUsedQuery()) and
  f = fc.getTarget() and
  f.hasGlobalOrStdName(["signal", "raise"])
select fc, "Use of <csignal> function '" + f.getQualifiedName() + "'."
