/**
 * @id c/misra/undef-should-not-be-used
 * @name RULE-20-5: #undef should not be used
 * @description Using the #undef preprocessor directive makes code more difficult to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-5
 *       maintainability
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from PreprocessorUndef d
where not isExcluded(d, Preprocessor2Package::undefShouldNotBeUsedQuery())
select d, "Use of undef found."
