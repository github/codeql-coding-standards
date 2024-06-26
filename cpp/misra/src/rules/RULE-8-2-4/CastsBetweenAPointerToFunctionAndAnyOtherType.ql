/**
 * @id cpp/misra/casts-between-a-pointer-to-function-and-any-other-type
 * @name RULE-8-2-4: Casts shall not be performed between a pointer to function and any other type
 * @description Casts shall not be performed between a pointer to function and any other type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-4
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.castsbetweenapointertofunctionandanyothertype_shared.CastsBetweenAPointerToFunctionAndAnyOtherType_shared

class CastsBetweenAPointerToFunctionAndAnyOtherTypeQuery extends CastsBetweenAPointerToFunctionAndAnyOtherType_sharedSharedQuery {
  CastsBetweenAPointerToFunctionAndAnyOtherTypeQuery() {
    this = ImportMisra23Package::castsBetweenAPointerToFunctionAndAnyOtherTypeQuery()
  }
}
