/**
 * @id c/cert/do-not-declare-or-define-a-reserved-identifier
 * @name DCL37-C: Do not declare or define a reserved identifier
 * @description Declaring a reserved identifier can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/dcl37-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Naming
import codingstandards.c.Keywords

from Element m, string name
where
  not isExcluded(m, Declarations1Package::doNotDeclareOrDefineAReservedIdentifierQuery()) and
  (
    m.(Macro).hasName(name) or
    m.(Declaration).hasGlobalName(name)
  ) and
  (
    Naming::Cpp14::hasStandardLibraryMacroName(name)
    or
    Naming::Cpp14::hasStandardLibraryObjectName(name)
    or
    Naming::Cpp14::hasStandardLibraryFunctionName(name)
    or
    name.regexpMatch("_[A-Z_].*")
    or
    name.regexpMatch("_.*") and m.(Declaration).hasGlobalName(name)
    or
    Keywords::isKeyword(name)
  )
select m, "Reserved identifier '" + name + "' is declared."
