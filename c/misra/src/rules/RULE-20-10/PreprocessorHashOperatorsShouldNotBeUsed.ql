/**
 * @id c/misra/preprocessor-hash-operators-should-not-be-used
 * @name RULE-20-10: The # and ## preprocessor operators should not be used
 * @description The order of evaluation for the '#' and '##' operators may differ between compilers,
 *              which can cause unexpected behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-10
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.hashoperatorsused.HashOperatorsUsed

class HashOperatorsUsedInQuery extends HashOperatorsUsedSharedQuery {
  HashOperatorsUsedInQuery() {
    this = Preprocessor1Package::preprocessorHashOperatorsShouldNotBeUsedQuery()
  }
}
