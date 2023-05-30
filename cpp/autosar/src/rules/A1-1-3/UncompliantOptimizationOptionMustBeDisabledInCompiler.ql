/**
 * @id cpp/autosar/uncompliant-optimization-option-must-be-disabled-in-compiler
 * @name A1-1-3: An uncompliant optimization option shall be disabled in the chosen compiler
 * @description An optimization option that disregards strict standard compliance shall not be
 *              turned on in the chosen compiler. Enabling optimizations that disregard compliance
 *              with the C++ Language Standard may create an output program that should strictly
 *              comply to the standard no longer valid.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a1-1-3
 *       maintainability
 *       correctness
 *       external/autosar/allocated-target/toolchain
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from File f, string flag
where
  not isExcluded(f, ToolchainPackage::uncompliantOptimizationOptionMustBeDisabledInCompilerQuery()) and
  exists(Compilation c | f = c.getAFileCompiled() |
    c.getAnArgument() = flag and
    flag =
      [
        "-Ofast", "-ffast-math", "-fgnu-keywords", "-fno-signed-zeros", "-menable-unsafe-fp-math",
        "-menable-no-nans", "-menable-no-infs", "-menable-unsafe-fp-math", "-ffinite-math-only",
        "-ffloat-store"
      ]
  )
select f, "File compiled with uncompliant optimization flag '" + flag + "'."
