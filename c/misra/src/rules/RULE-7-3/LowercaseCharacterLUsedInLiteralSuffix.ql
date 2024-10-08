/**
 * @id c/misra/lowercase-character-l-used-in-literal-suffix
 * @name RULE-7-3: The lowercase character l shall not be used in a literal suffix
 * @description Using the lowercase letter l in a literal suffix can be mistaken for other
 *              characters such as 1.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-7-3
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Literals

from IntegerLiteral l
where
  not isExcluded(l, SyntaxPackage::lowercaseCharacterLUsedInLiteralSuffixQuery()) and
  exists(l.getValueText().indexOf("l"))
select l, "Lowercase 'l' used as a literal suffix."
