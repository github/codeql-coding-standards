/**
 * @id cpp/autosar/bind-used
 * @name A18-9-1: The std::bind shall not be used
 * @description Neither std::bind nor boost::bind shall be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-9-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isBind(FunctionCall fc) {
  fc.getTarget().getQualifiedName() in ["std::bind", "std::bind1st", "std::bind2nd"]
}

from FunctionCall fc
where
  isBind(fc) and
  not isExcluded(fc, BannedFunctionsPackage::bindUsedQuery())
select fc, "Prefer lambdas to using " + fc.getTarget().getQualifiedName() + "."
