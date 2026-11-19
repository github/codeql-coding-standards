/**
 * @id c/misra/reserved-macro-name
 * @name RULE-20-15: Reserved identifiers shall not be defined or undefined
 * @description Defining or undefining reserved names can cause undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-15
 *       correctness
 *       external/misra/c/2025
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.ReservedMacroNames

from PreprocessorDirective directive, string name
where
  not isExcluded(directive, Preprocessor4Package::reservedMacroNameQuery()) and
  name = getReservedMacroName(directive)
select directive, "Reserved identifier '" + name + "' has been undefined or redefined."
