/**
 * @id cpp/autosar/reserved-identifiers-macros-and-functions-are-defined-redefined-or-undefined
 * @name A17-0-1: Reserved identifiers, macros and functions shall not be defined, redefined, or undefined
 * @description It is generally bad practice to #undef a macro that is defined in the standard
 *              library. It is also bad practice to #define a macro name that is a C++ reserved
 *              identifier, or C++ keyword or the name of any macro, object or function in the
 *              standard library. For example, there are some specific reserved words and function
 *              names that are known to give rise to undefined behavior if they are redefined or
 *              undefined, including defined, __LINE__, __FILE__, __DATE__, __TIME__, __STDC__,
 *              errno and assert.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a17-0-1
 *       correctness
 *       maintainability
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Naming

predicate isLocatedInNamespaceBody(NamespaceDeclarationEntry n, PreprocessorDirective m) {
  m.getFile() = n.getFile() and
  m.getLocation().getStartLine() >= n.getBodyLocation().getStartLine() and
  m.getLocation().getEndLine() <= n.getBodyLocation().getEndLine()
}

from PreprocessorDirective ppd, string name
where
  not isExcluded(ppd,
    BannedLibrariesPackage::reservedIdentifiersMacrosAndFunctionsAreDefinedRedefinedOrUndefinedQuery()) and
  (
    ppd.(Macro).hasName(name)
    or
    ppd.(PreprocessorUndef).getName() = name
  ) and
  (
    Naming::Cpp14::hasStandardLibraryMacroName(name)
    or
    Naming::Cpp14::hasStandardLibraryObjectName(name)
    or
    // Reserved everywhere according to [global.names]
    name.regexpMatch("(__|_[A-Z]).*")
    or
    // Reserved only in the global namespace according to [global.names]
    name.regexpMatch("_.*") and
    not isLocatedInNamespaceBody(_, ppd)
  )
select ppd, "Reserved identifier '" + name + "' has been undefined or redefined."
