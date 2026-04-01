/**
 * @id cpp/misra/volatile-qualifier-not-used-appropriately
 * @name RULE-10-1-2: The volatile qualifier shall be used appropriately
 * @description Using the volatile qualifier on certain entities can lead to undefined behavior or
 *              code that is hard to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-1-2
 *       correctness
 *       readability
 *       maintainability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from Declaration d
where
  not isExcluded(d, Declarations4Package::volatileQualifierNotUsedAppropriatelyQuery()) and
  d.getADeclarationEntry().getType().isVolatile() and
  (
    d instanceof LocalVariable or
    exists(d.(Parameter).getFunction()) or
    d instanceof Function or
    d.(Variable).isStructuredBinding()
  )
select d, "Volatile entity declared."
