/**
 * @id cpp/cert/function-reuses-reserved-name
 * @name DCL51-CPP: Reuse of reserved standard library name by a function
 * @description Declaration of a function identifier in the context where it is reserved results in
 *              undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl51-cpp
 *       maintainability
 *       readability
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Naming

from TopLevelFunction f
where
  not isExcluded(f, NamingPackage::functionReusesReservedNameQuery()) and
  Naming::Cpp14::hasStandardLibraryFunctionName(f.getName())
select f, "The function $@ reuses a reserved standard library name.", f, f.getName()
