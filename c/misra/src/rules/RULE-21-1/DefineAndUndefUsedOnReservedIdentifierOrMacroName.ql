/**
 * @id c/misra/define-and-undef-used-on-reserved-identifier-or-macro-name
 * @name RULE-21-1: #define and #undef shall not be used on a reserved identifier or reserved macro name
 * @description The use of #define and #undef on reserved identifiers or macro names can result in
 *              undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-1
 *       correctness
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Naming

from PreprocessorDirective p, string name
where
  not isExcluded(p, Preprocessor4Package::defineAndUndefUsedOnReservedIdentifierOrMacroNameQuery()) and
  (
    p.(Macro).hasName(name)
    or
    p.(PreprocessorUndef).getName() = name
  ) and
  (
    Naming::Cpp14::hasStandardLibraryMacroName(name)
    or
    Naming::Cpp14::hasStandardLibraryObjectName(name)
    or
    name.regexpMatch("_.*")
    or
    name = "defined"
  )
select p, "Reserved identifier '" + name + "' has been undefined or redefined."
