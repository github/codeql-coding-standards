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

class CompilationWithNoWarnings extends Compilation {
  CompilationWithNoWarnings() {
    getAnArgument() = "-w" or
    not exists(EnableWarningFlag enableFlag | 
      this.getAnArgument() = enableFlag and
      not exists(DisableWarningFlag disableFlag |
        this.getAnArgument() = disableFlag and
        enableFlag.getWarningType() = disableFlag.getWarningType()
      )
    )
  }
}

class CompilationArgument extends string {
  Compilation compilation;

  CompilationArgument() {
    this = compilation.getAnArgument()
  }
}

/**
 * Compiler flags of type -Wfoo or -Wfoo=bar, which enables the `foo` warning.
 */
class EnableWarningFlag extends CompilationArgument {
  string warningType;

  EnableWarningFlag() {
    warningType = regexpCapture("^-W([\\w-]+)(=.*)?$", 1)
    and not this instanceof DisableWarningFlag
  }

  string getWarningType() {
    result = warningType
  }
}

/**
 * Compiler flags of type -Wno-foo or -Wfoo=0, which disables the `foo` warning
 * and overrules -Wfoo.
 */
class DisableWarningFlag extends CompilationArgument {
  string warningType;

  DisableWarningFlag() {
    warningType = regexpCapture("^-Wno-([\\w-]+)", 1) or
    warningType = regexpCapture("^-W([\\w-]+)=0", 1)
  }

  string getWarningType() {
    result = warningType
  }
}

from File f
where
  not isExcluded(f, ToolchainPackage::compilerWarningLevelNotInComplianceQuery()) and
  exists(CompilationWithNoWarnings c | f = c.getAFileCompiled() | not hasResponseFileArgument(c))
select f, "No warning-level options were used in the compilation of '" + f.getBaseName() + "'."
