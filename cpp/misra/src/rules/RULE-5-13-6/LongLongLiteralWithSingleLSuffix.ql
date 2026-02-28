/**
 * @id cpp/misra/long-long-literal-with-single-l-suffix
 * @name RULE-5-13-6: An integer-literal of type long long shall not use a single L or l in any suffix
 * @description Declaring a long long integer literal with a single L or l in the suffix is
 *              misleading and can cause confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-13-6
 *       scope/single-translation-unit
 *       readability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Cpp14Literal

from Cpp14Literal::IntegerLiteral literal, Cpp14Literal::IntegerLiteralSuffix suffix
where
  not isExcluded(literal, Expressions2Package::longLongLiteralWithSingleLSuffixQuery()) and
  suffix = literal.getSuffix() and
  suffix.getLCount() = 1 and
  literal.getType() instanceof LongLongType
select literal,
  "Integer literal declared with suffix '" + suffix +
    "' indicative of a long type, but has actual type '" + literal.getType().toString() + "'."
