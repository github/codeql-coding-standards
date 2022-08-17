/**
 * @id cpp/autosar/functions-defined-using-the-ellipsis-notation
 * @name A8-4-1: Functions shall not be defined using the ellipsis notation
 * @description Functions shall not be defined using the ellipsis notation.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a8-4-1
 *       correctness
 *       security
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Function f
where
  not isExcluded(f, BannedSyntaxPackage::functionsDefinedUsingTheEllipsisNotationQuery()) and
  f.isVarargs()
select f, "Function " + f.getName() + " is declared with ellipses (...) operator."
