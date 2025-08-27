/**
 * @id c/misra/define-and-undef-used-on-reserved-identifier-or-macro-name
 * @name RULE-21-1: #define and #undef shall not be used on a reserved identifier or reserved macro name
 * @description The use of #define and #undef on reserved identifiers or macro names can result in
 *              undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-1
 *       correctness
 *       readability
 *       maintainability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.ReservedNames

from PreprocessorDirective p, string message
where
  not isExcluded(p, Preprocessor4Package::defineAndUndefUsedOnReservedIdentifierOrMacroNameQuery()) and
  ReservedNames::C11::isAReservedIdentifier(p, message, false)
select p, message
