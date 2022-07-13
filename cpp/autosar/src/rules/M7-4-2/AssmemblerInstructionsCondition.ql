/**
 * @id cpp/autosar/assmembler-instructions-condition
 * @name M7-4-2: Assembler instructions shall only be introduced using the asm declaration
 * @description Assembler instructions not introduced using the asm declaration is confusing and can
 *              cause inconsitent behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m7-4-2
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from PreprocessorPragma pragma
where
  not isExcluded(pragma, FunctionsPackage::assmemblerInstructionsConditionQuery()) and
  pragma.getHead().matches("asm")
select pragma, "The assembler instructions do not use asm declarations."
