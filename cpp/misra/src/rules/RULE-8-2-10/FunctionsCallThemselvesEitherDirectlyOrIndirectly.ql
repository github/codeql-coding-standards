/**
 * @id cpp/misra/functions-call-themselves-either-directly-or-indirectly
 * @name RULE-8-2-10: Functions shall not call themselves, either directly or indirectly
 * @description Functions shall not call themselves, either directly or indirectly.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-10
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.functionscallthemselveseitherdirectlyorindirectly.FunctionsCallThemselvesEitherDirectlyOrIndirectly

class FunctionsCallThemselvesEitherDirectlyOrIndirectlyQuery extends FunctionsCallThemselvesEitherDirectlyOrIndirectlySharedQuery
{
  FunctionsCallThemselvesEitherDirectlyOrIndirectlyQuery() {
    this = ImportMisra23Package::functionsCallThemselvesEitherDirectlyOrIndirectlyQuery()
  }
}
