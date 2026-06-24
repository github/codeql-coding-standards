/**
 * @id cpp/misra/volatile-qualifier-not-used-appropriately
 * @name RULE-10-1-2: The volatile qualifier shall be used appropriately
 * @description Using the volatile qualifier on certain entities has behavior that is not
 *              well-defined and can make code harder to understand, especially as its application
 *              to these entities does not prevent data races or guarantee safe multithreading.
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
select d, "Volatile entity '" + d.getName() + "' declared."
