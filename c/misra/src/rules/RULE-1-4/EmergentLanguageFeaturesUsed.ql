/**
 * @id c/misra/emergent-language-features-used
 * @name RULE-1-4: Emergent language features shall not be used
 * @description Emergent language features may have unpredictable behavior and should not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-1-4
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Emergent

from C11::EmergentLanguageFeature ef
where not isExcluded(ef, Language2Package::emergentLanguageFeaturesUsedQuery())
select ef, "Usage of emergent language feature."

