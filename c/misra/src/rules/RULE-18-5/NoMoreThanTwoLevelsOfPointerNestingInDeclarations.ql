/**
 * @id c/misra/no-more-than-two-levels-of-pointer-nesting-in-declarations
 * @name RULE-18-5: Declarations should contain no more than two levels of pointer nesting
 * @description Declarations with more than two levels of pointer nesting can result in code that is
 *              difficult to read and understand.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-5
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.donotusemorethantwolevelsofpointerindirection.DoNotUseMoreThanTwoLevelsOfPointerIndirection

class NoMoreThanTwoLevelsOfPointerNestingInDeclarationsQuery extends DoNotUseMoreThanTwoLevelsOfPointerIndirectionSharedQuery {
  NoMoreThanTwoLevelsOfPointerNestingInDeclarationsQuery() {
    this = Pointers1Package::noMoreThanTwoLevelsOfPointerNestingInDeclarationsQuery()
  }
}
