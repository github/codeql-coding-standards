/**
 * @id c/misra/macro-defined-with-the-same-name-as-keyword
 * @name RULE-20-4: A macro shall not be defined with the same name as a keyword
 * @description Redefinition of keywords is confusing and in the case where the standard library is
 *              included where that keyword is defined, the redefinition will result in undefined
 *              behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-4
 *       correctness
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.CKeywords

from Macro m, string name
where
  not isExcluded(m, Preprocessor4Package::macroDefinedWithTheSameNameAsKeywordQuery()) and
  m.hasName(name) and
  Keywords::isKeyword(name)
select m, "Redefinition of keyword '" + name + "'."
