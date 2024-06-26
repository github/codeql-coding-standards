/**
 * @id cpp/misra/overriding-shall-specify-different-default-arguments
 * @name RULE-13-3-2: Parameters in an overriding virtual function shall not specify different default arguments
 * @description Parameters in an overriding virtual function shall not specify different default
 *              arguments.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-3-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.overridingshallspecifydifferentdefaultarguments_shared.OverridingShallSpecifyDifferentDefaultArguments_shared

class OverridingShallSpecifyDifferentDefaultArgumentsQuery extends OverridingShallSpecifyDifferentDefaultArguments_sharedSharedQuery {
  OverridingShallSpecifyDifferentDefaultArgumentsQuery() {
    this = ImportMisra23Package::overridingShallSpecifyDifferentDefaultArgumentsQuery()
  }
}
