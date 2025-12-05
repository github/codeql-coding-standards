/**
 * @id cpp/misra/no-c-style-or-functional-casts
 * @name RULE-8-2-2: C-style casts and functional notation casts shall not be used
 * @description Using C-style casts or functional notation casts allows unsafe type conversions and
 *              makes code harder to maintain compared to using named casts like const_cast,
 *              dynamic_cast, static_cast and reinterpret_cast.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-2
 *       scope/single-translation-unit
 *       readability
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.CStyleCasts
import codingstandards.cpp.AlertReporting

class MISRACPPProhibitedCStyleCasts extends ExplicitUserDefinedCStyleCast {
  MISRACPPProhibitedCStyleCasts() {
    // MISRA C++ permits casts to void types
    not getType() instanceof VoidType
  }
}

from Element reportingElement, MISRACPPProhibitedCStyleCasts c
where
  not isExcluded(c, Conversions2Package::noCStyleOrFunctionalCastsQuery()) and
  reportingElement = MacroUnwrapper<MISRACPPProhibitedCStyleCasts>::unwrapElement(c) and
  exists(reportingElement.getFile().getRelativePath()) // within user code - validated during testing
select reportingElement, "Use of explicit c-style cast to " + c.getType().getName() + "."
