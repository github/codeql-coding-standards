/**
 * @id c/misra/values-returned-by-locale-setting-used-as-ptr-to-const
 * @name RULE-21-19: The pointers returned by environment functions should be treated as const
 * @description The pointers returned by the Standard Library functions localeconv, getenv,
 *              setlocale or, strerror shall only be used as if they have pointer to const-qualified
 *              type.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-19
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.constlikereturnvalue.ConstLikeReturnValue

class ValuesReturnedByLocaleSettingUsedAsPtrToConstQuery extends ConstLikeReturnValueSharedQuery {
  ValuesReturnedByLocaleSettingUsedAsPtrToConstQuery() {
    this = Contracts2Package::valuesReturnedByLocaleSettingUsedAsPtrToConstQuery()
  }
}
