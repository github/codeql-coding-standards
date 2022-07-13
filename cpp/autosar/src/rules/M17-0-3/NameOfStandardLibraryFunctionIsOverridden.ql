/**
 * @id cpp/autosar/name-of-standard-library-function-is-overridden
 * @name M17-0-3: The names of standard library functions shall not be overridden
 * @description Reusing the names of standard library functions can lead to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m17-0-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Naming

predicate isGlobal(Function f) { f.hasGlobalName(_) }

from TopLevelFunction f
where
  not isExcluded(f, NamingPackage::nameOfStandardLibraryFunctionIsOverriddenQuery()) and
  Naming::Cpp14::hasStandardLibraryFunctionName(f.getName()) and
  f.fromSource() and
  isGlobal(f)
select f,
  "Function " + f.getName() + " overrides standard library function " +
    Naming::Cpp14::getQualifiedStandardLibraryFunctionName(f.getName()) + "."
