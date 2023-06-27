/**
 * @id cpp/autosar/compiler-implementation-shall-comply-with-cpp14standard
 * @name A0-4-3: The implementations in the chosen compiler shall strictly comply with the C++14 Language Standard
 * @description It is important to determine whether implementations provided by the chosen compiler
 *              strictly follow the ISO/IEC 14882:2014 C++ Language Standard.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-4-3
 *       maintainability
 *       external/autosar/allocated-target/toolchain
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from File f, string flag
where
  not isExcluded(f, ToolchainPackage::compilerImplementationShallComplyWithCPP14StandardQuery()) and
  exists(Compilation c | f = c.getAFileCompiled() |
    flag =
      max(string std, int index |
        c.getArgument(index) = std and std.matches("-std=%")
      |
        std order by index
      )
  ) and
  flag != "-std=c++14"
select f,
  "File '" + f.getBaseName() + "' compiled with flag '" + flag +
    "' which does not strictly comply with ISO C++14."
