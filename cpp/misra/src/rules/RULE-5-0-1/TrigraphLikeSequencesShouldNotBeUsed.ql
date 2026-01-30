/**
 * @id cpp/misra/trigraph-like-sequences-should-not-be-used
 * @name RULE-5-0-1: Trigraph-like sequences should not be used
 * @description Using trigraph-like sequences can lead to developer confusion.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/misra/id/rule-5-0-1
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from StringLiteral s, int occurrenceOffset
where
  not isExcluded(s, TrigraphPackage::trigraphLikeSequencesShouldNotBeUsedQuery()) and
  exists(s.getValue().regexpFind("\\?\\?[=/'()!<>-]", _, occurrenceOffset)) and
  //one escape character is enough to mean this isnt a trigraph-like sequence
  not exists(s.getASimpleEscapeSequence(_, occurrenceOffset + 1))
select s, "Trigraph-like sequence used in string literal."
