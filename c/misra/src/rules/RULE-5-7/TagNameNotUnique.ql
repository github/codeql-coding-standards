/**
 * @id c/misra/tag-name-not-unique
 * @name RULE-5-7: A tag name shall be a unique identifier
 * @description Reusing a tag name compared to the name of any tag can cause confusion and make code
 *              harder to read.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-7
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers

from Struct s, InterestingIdentifiers s2
where
  not isExcluded(s, Declarations3Package::tagNameNotUniqueQuery()) and
  not isExcluded(s2, Declarations3Package::tagNameNotUniqueQuery()) and
  not s = s2 and
  s.getName() = s2.getName() and
  not s.getName() = "struct <unnamed>" and
  not s.getName() = "union <unnamed>" and
  not s.getName() = s2.(TypedefType).getBaseType().toString()
select s, "Tag name is nonunique compared to $@.", s2, s2.getName()
