/**
 * @id cpp/misra/pointers-returned-by-locale-functions-must-be-used-as-const
 * @name RULE-25-5-2: The pointers returned by environment functions should be treated as const
 * @description The pointers returned by the C++ Standard Library functions localeconv, getenv,
 *              setlocale or strerror must only be used as if they have pointer to const-qualified
 *              type.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-25-5-2
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.constlikereturnvalue.ConstLikeReturnValue

class PointersReturnedByLocaleFunctionsMustBeUsedAsConstQuery extends ConstLikeReturnValueSharedQuery
{
  PointersReturnedByLocaleFunctionsMustBeUsedAsConstQuery() {
    this = ImportMisra23Package::pointersReturnedByLocaleFunctionsMustBeUsedAsConstQuery()
  }
}
