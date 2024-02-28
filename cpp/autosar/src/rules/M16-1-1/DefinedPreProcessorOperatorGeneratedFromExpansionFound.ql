/**
 * @id cpp/autosar/defined-pre-processor-operator-shall-only-be-used-in-one-of-the-two-standard-forms
 * @name M16-1-1: The defined pre-processor operator shall only be used in one of the two standard forms
 * @description
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m16-1-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.PreprocessorDirective
import DefinedMacro

from PreprocessorIfOrElif e, MacroUsesDefined m
where
  not isExcluded(e, MacrosPackage::definedPreProcessorOperatorInOneOfTheTwoStandardFormsQuery()) and
  // A`#if` or `#elif` which uses a macro which uses `defined`
  exists(e.getHead().regexpFind(m.getRegexForMatch(), _, _))
select e, "The macro $@ expands to 'defined'", m, m.getName()
