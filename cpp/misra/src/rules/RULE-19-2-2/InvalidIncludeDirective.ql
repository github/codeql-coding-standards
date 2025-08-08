/**
 * @id cpp/misra/invalid-include-directive
 * @name RULE-19-2-2: The #include directive shall be followed by either a <filename> or "filename" sequence
 * @description Include directives shall only use the <filename> or "filename" forms.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-19-2-2
 *       scope/single-translation-unit
 *       maintainability
 *       readability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from Include include
where
  not isExcluded(include, Preprocessor2Package::invalidIncludeDirectiveQuery()) and
  // Check for < followed by (not >)+ followed by >, or " followed by (not ")+ followed by ".
  not include.getIncludeText().trim().regexpMatch("^(<[^>]+>|\"[^\"]+\")$")
select include, "Non-compliant #include directive text '" + include.getHead() + "'."
