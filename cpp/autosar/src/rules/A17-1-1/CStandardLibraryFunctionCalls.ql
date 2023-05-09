/**
 * @id cpp/autosar/c-standard-library-function-calls
 * @name A17-1-1: C Standard Library function calls should be encapsulated
 * @description Calls to C Standard Library functions should be encapsulated to clearly isolate
 *              responsibility for low level checks and error handling.
 * @kind problem
 * @precision low
 * @problem.severity recommendation
 * @tags external/autosar/id/a17-1-1
 *       maintainability
 *       external/autosar/audit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Naming
import codingstandards.cpp.StdNamespace

FunctionCall nonCompliantCStdlibCalls(File f) {
  result =
    any(FunctionCall fc, string name, string qname, int qname_count |
      f = fc.getFile() and
      name = fc.getTarget().getName() and
      Naming::Cpp14::hasStandardLibraryFunctionName(name) and
      qname = Naming::Cpp14::getQualifiedStandardLibraryFunctionName(name) and
      qname_count = count(Naming::Cpp14::getQualifiedStandardLibraryFunctionName(name)) and
      (
        not exists(fc.getQualifier()) and
        (
          // the set `q` can contain qualified names both with and without the `std` namespace.
          // in this case, only a call to the function within the `std` namespace is compliant.
          qname_count > 1 and
          not exists(NameQualifier nq |
            nq = fc.getNameQualifier() and nq.getQualifyingElement().getName() = "std"
          )
          or
          // if the qualified standard library function name does not specify a namespace, then the
          // standard library function is either in the global namespace (such as in C) or within
          // the `std` namespace. therefore, ignore calls with qualifiers other than 'std'.
          name = qname and
          qname_count <= 1 and
          (
            not exists(fc.getNameQualifier()) and
            // also handle implicit namespace scope
            not exists(Namespace caller_ns, Namespace callee_ns |
              caller_ns = fc.getEnclosingFunction().getNamespace() and
              callee_ns = fc.getTarget().getNamespace() and
              not callee_ns instanceof GlobalNamespace and
              caller_ns = callee_ns
            )
            or
            exists(NameQualifier nq |
              nq = fc.getNameQualifier() and
              (
                nq.getQualifyingElement() instanceof GlobalNamespace or
                nq.getQualifyingElement() instanceof StdNS
              )
            )
          )
        )
      )
    |
      fc
    )
}

from File f, string targets
where
  not isExcluded(f, FunctionsPackage::cStandardLibraryFunctionCallsQuery()) and
  targets =
    strictconcat(string target_name |
      target_name = nonCompliantCStdlibCalls(f).getTarget().getName()
    |
      target_name, ", "
    )
select f,
  "[AUDIT] Confirm encapsulation of function calls to C standard library function(s) " + targets +
    "."
