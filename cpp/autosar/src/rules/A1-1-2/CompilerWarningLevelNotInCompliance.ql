/**
 * @id cpp/autosar/compiler-warning-level-not-in-compliance
 * @name A1-1-2: A warning level of the compilation process shall be set in compliance with project policies
 * @description If compiler enables the high warning level, then it is able to generate useful
 *              warning messages that point out potential run-time problems during compilation time.
 *              The information can be used to resolve certain errors before they occur at run-time.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a1-1-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/allocated-target/toolchain
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate hasResponseFileArgument(Compilation c) { c.getAnArgument().matches("@%") }

predicate hasWarningOption(Compilation c) { c.getAnArgument().regexpMatch("-W[\\w=-]+") }

from File f
where
  not isExcluded(f, ToolchainPackage::compilerWarningLevelNotInComplianceQuery()) and
  exists(Compilation c | f = c.getAFileCompiled() |
    not hasResponseFileArgument(c) and
    not hasWarningOption(c)
  )
select f, "No warning-level options were used in the compilation of '" + f.getBaseName() + "'."
