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
import DefinedMacro

from DefinedMacro m, PreprocessorBranch e
where
  (
    e instanceof PreprocessorIf or
    e instanceof PreprocessorElif
  ) and
  (
    e.getHead().regexpMatch(m.getAUse().getHead() + "\\s*\\(.*")
    or
    e.getHead().regexpMatch(m.getAUse().getHead().replaceAll("(", "\\(").replaceAll(")", "\\)"))
  ) and
  not isExcluded(e)
select e, "The macro $@ expands to 'defined'", m, m.getName()
