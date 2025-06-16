/**
 * @id cpp/cert/object-reuses-reserved-name
 * @name DCL51-CPP: Reuse of reserved standard library name by an object
 * @description Declaration of an object identifier in the context where it is reserved results in
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

from GlobalOrNamespaceVariable v
where
  not isExcluded(v, NamingPackage::objectReusesReservedNameQuery()) and
  (
    Naming::Cpp14::hasStandardLibraryObjectName(v.getName()) or
    Naming::Cpp14::hasStandardLibraryMacroName(v.getName())
  )
select v, "The variable $@ reuses a reserved standard library name.", v, v.getName()
