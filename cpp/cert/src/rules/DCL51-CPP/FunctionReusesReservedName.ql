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

from TopLevelFunction f
where
  not isExcluded(f, NamingPackage::functionReusesReservedNameQuery()) and
  Naming::Cpp14::hasStandardLibraryFunctionName(f.getName())
select f, "The function $@ reuses a reserved standard library name.", f, f.getName()
