/**
 * @id cpp/autosar/name-of-standard-library-macro-or-object-reused
 * @name M17-0-2: The names of standard library macros and objects shall not be reused
 * @description Reusing the names of standard library macros and objects can lead to developer
 *              confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m17-0-2
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.StandardLibraryNames

module TargetedCLibrary = CStandardLibrary::C99;

module TargetedCppLibrary = CppStandardLibrary::Cpp14;

from Locatable l, string s, string t, string header, string standard
where
  not isExcluded(l, NamingPackage::nameOfStandardLibraryMacroOrObjectReusedQuery()) and
  l.fromSource() and
  (
    s = l.(Macro).getName() and t = "Macro"
    or
    s = l.(GlobalOrNamespaceVariable).getName() and t = "Object"
  ) and
  (
    standard = TargetedCppLibrary::getName() and
    (
      TargetedCppLibrary::hasMacroName(header, s, _)
      or
      TargetedCppLibrary::hasObjectName(header, _, s, _, _)
    )
    or
    standard = TargetedCLibrary::getName() and
    (
      header = max(string candidateHeader | TargetedCLibrary::hasMacroName(candidateHeader, s, _))
      or
      header =
        max(string candidateHeader | TargetedCLibrary::hasObjectName(candidateHeader, _, s, _, _))
    )
  )
select l,
  t + " reuses the name " + s + " from the " + standard + " standard library header <" + header +
    ">."
