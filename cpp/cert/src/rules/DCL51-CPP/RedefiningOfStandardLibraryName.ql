/**
 * @id cpp/cert/redefining-of-standard-library-name
 * @name DCL51-CPP: Redefining of names declared in standard library header using #define or #undef
 * @description A translation unit that includes a standard library header shall not #define or
 *              #undef names declared in any standard library header.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl51-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Naming
import codingstandards.cpp.Header

predicate isReserved(string s) {
  Naming::Cpp14::hasStandardLibraryFunctionName(s)
  or
  Naming::Cpp14::hasStandardLibraryMacroName(s)
  or
  Naming::Cpp14::hasStandardLibraryObjectName(s)
}

from Include i, PreprocessorDirective d, string s
where
  not isExcluded(d, NamingPackage::redefiningOfStandardLibraryNameQuery()) and
  i.getFile() = d.getFile() and
  Header::Cpp14::hasStandardLibraryHeaderFileName(i.getIncludeText()) and
  (
    s = d.(PreprocessorUndef).getName()
    or
    s = d.(Macro).getName()
  ) and
  isReserved(s)
select d, "Redefinition of " + s + " declared in a standard library header."
