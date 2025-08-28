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
import codingstandards.cpp.StandardLibraryNames

from TopLevelFunction f, string functionName, string header
where
  not isExcluded(f, NamingPackage::nameOfStandardLibraryFunctionIsOverriddenQuery()) and
  f.hasGlobalName(functionName) and
  /*
   * The rule does not define what it means by "standard library function", but we will
   * assume that it is a non-member function which is declared in the global namespace.
   * Functions declared in `std` only can't be easily "replaced" in the way the rule is
   * concerned about (without extending 'std'), and so are excluded.
   */

  (
    // Directly defined by C++
    CppStandardLibrary::Cpp14::hasFunctionName(header, "", "", functionName, _, _, _)
    or
    // Defined by C and inherited by C++
    CStandardLibrary::C11::hasFunctionName(header, "", "", functionName, _, _, _)
  ) and
  f.fromSource()
select f,
  "Function " + functionName + " overrides a standard library function from '" + header + "'."
