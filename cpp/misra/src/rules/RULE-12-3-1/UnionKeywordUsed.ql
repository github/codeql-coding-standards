/**
 * @id cpp/misra/union-keyword-used
 * @name RULE-12-3-1: The union keyword shall not be used
 * @description Using unions should be avoided and 'std::variant' should be used as a type-safe
 *              alternative.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-3-1
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from Union u
where not isExcluded(u, BannedSyntaxPackage::unionsUsedQuery())
select u, "'" + u.getName() + "' is a union which is prohibited."
