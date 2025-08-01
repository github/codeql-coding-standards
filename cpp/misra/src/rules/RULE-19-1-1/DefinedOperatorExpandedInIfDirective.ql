/**
 * @id cpp/misra/defined-operator-expanded-in-if-directive
 * @name RULE-19-1-1: The defined preprocessor operator shall be used appropriately
 * @description Macro expansions that produce the token 'defined' inside of an if directive result
 *              in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-1-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from PreprocessorIf ifDirective, MacroInvocation mi
where
  not isExcluded(ifDirective, PreprocessorPackage::definedOperatorExpandedInIfDirectiveQuery()) and
  ifDirective.getLocation().subsumes(mi.getLocation()) and
  mi.getMacro().getBody().regexpMatch(".*defined.*")
select ifDirective,
  "If directive contains macro expansion including the token 'defined' from macro $@, which results in undefined behavior.",
  mi.getMacro(), mi.getMacroName()
