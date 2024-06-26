/**
 * @id cpp/misra/csignal-types-shall-not-be-used
 * @name RULE-21-10-3: The signal-handling types of <csignal> shall not be used
 * @description The types provided by the standard header file <csignal> shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-10-3
 *       maintainability
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.csignaltypesused_shared.CsignalTypesUsed_shared

class CsignalTypesShallNotBeUsedQuery extends CsignalTypesUsed_sharedSharedQuery {
  CsignalTypesShallNotBeUsedQuery() {
    this = ImportMisra23Package::csignalTypesShallNotBeUsedQuery()
  }
}
