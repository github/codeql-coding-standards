/**
 * @id cpp/misra/nullptr-not-the-only-form-of-the-null-pointer-constant
 * @name RULE-7-11-1: nullptr shall be the only form of the null-pointer-constant
 * @description nullptr shall be the only form of the null-pointer-constant.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-11-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.nullptrnottheonlyformofthenullpointerconstant.NullptrNotTheOnlyFormOfTheNullPointerConstant

class NullptrNotTheOnlyFormOfTheNullPointerConstantQuery extends NullptrNotTheOnlyFormOfTheNullPointerConstantSharedQuery
{
  NullptrNotTheOnlyFormOfTheNullPointerConstantQuery() {
    this = ImportMisra23Package::nullptrNotTheOnlyFormOfTheNullPointerConstantQuery()
  }
}
