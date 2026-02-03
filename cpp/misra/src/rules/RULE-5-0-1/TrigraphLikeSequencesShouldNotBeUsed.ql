/**
 * @id cpp/misra/trigraph-like-sequences-should-not-be-used
 * @name RULE-5-0-1: Trigraph-like sequences should not be used
 * @description Using trigraph-like sequences can lead to developer confusion.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/misra/id/rule-5-0-1
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

class CanContainSequenceType extends Locatable {
  CanContainSequenceType() {
    this instanceof StringLiteral
    or
    this instanceof Comment
    or
    this instanceof Macro
  }

  string getContent() {
    result = this.(StringLiteral).getValue()
    or
    result = this.(Comment).getContents()
    or
    result = this.(Macro).getBody()
  }
}

from CanContainSequenceType s, int occurrenceOffset, string substring
where
  not isExcluded(s, TrigraphPackage::trigraphLikeSequencesShouldNotBeUsedQuery()) and
  substring = s.getContent().regexpFind("\\?\\?[=/'()!<>-]", _, occurrenceOffset) and
  //one escape character is enough to mean this isnt a trigraph-like sequence
  not exists(s.(StringLiteral).getASimpleEscapeSequence(_, occurrenceOffset + 1))
select s, "Trigraph-like sequence found: '" + substring + "'."
