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
import codingstandards.cpp.StandardLibraryNames
import codingstandards.cpp.StdNamespace

FunctionCall nonCompliantCStdlibCalls(File f) {
  result =
    any(FunctionCall fc, Function function, string name |
      f = fc.getFile() and
      function = fc.getTarget() and
      name = function.getName() and
      // Has a name from the C99 library
      CStandardLibrary::C99::hasFunctionName(_, "", "", name, _, _, _) and
      // The C function is either declared in the global namespace and imported into std or vice versa
      (
        function.getNamespace() instanceof StdNS
        or
        function.getNamespace() instanceof GlobalNamespace
      ) and
      // No function qualifier
      not exists(fc.getQualifier())
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
