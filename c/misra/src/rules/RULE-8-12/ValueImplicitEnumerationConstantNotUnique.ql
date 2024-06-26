/**
 * @id c/misra/value-implicit-enumeration-constant-not-unique
 * @name RULE-8-12: Within an enumerator list, the value of an implicitly-specified enumeration constant shall be unique
 * @description Using an implicitly specified enumeration constant that is not unique (with respect
 *              to an explicitly specified constant) can lead to unexpected program behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-12
 *       correctness
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.nonuniqueenumerationconstant_shared.NonUniqueEnumerationConstant_shared

class ValueImplicitEnumerationConstantNotUniqueQuery extends NonUniqueEnumerationConstant_sharedSharedQuery
{
  ValueImplicitEnumerationConstantNotUniqueQuery() {
    this = Declarations7Package::valueImplicitEnumerationConstantNotUniqueQuery()
  }
}
