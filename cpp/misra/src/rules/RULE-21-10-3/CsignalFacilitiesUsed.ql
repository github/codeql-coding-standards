/**
 * @id cpp/misra/csignal-facilities-used
 * @name RULE-21-10-3: The facilities provided by the standard header file <csignal> shall not be used
 * @description Signal handling contains implementation-defined and undefined behaviour.
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
import codingstandards.cpp.rules.csignalfunctionsused.CsignalFunctionsUsed

class CsignalFacilitiesUsedQuery extends CsignalFunctionsUsedSharedQuery {
  CsignalFacilitiesUsedQuery() { this = ImportMisra23Package::csignalFacilitiesUsedQuery() }
}
