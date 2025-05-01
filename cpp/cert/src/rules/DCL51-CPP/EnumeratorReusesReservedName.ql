/**
 * @id cpp/cert/enumerator-reuses-reserved-name
 * @name DCL51-CPP: Reuse of reserved standard library name by a enumerator
 * @description Declaration of a enumerator identifier in the context where it is reserved results
 *              in undefined behavior.
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

from EnumConstant c
where
  not isExcluded(c, NamingPackage::enumeratorReusesReservedNameQuery()) and
  Naming::Cpp14::hasStandardLibraryMacroName(c.getName())
select c, "The enumerator $@ reuses a reserved standard library name.", c, c.getName()
