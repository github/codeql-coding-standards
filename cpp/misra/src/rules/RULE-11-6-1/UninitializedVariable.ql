/**
 * @id cpp/misra/uninitialized-variable
 * @name RULE-11-6-1: All variables should be initialized, otherwise it may lead to a read of uninitialized memory which is undefined behavior.
 * @description All variables should be initialized
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-6-1
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.InitializationContext

from UninitializedVariable v
where not isExcluded(v, Declarations7Package::uninitializedVariableQuery())
select v, "Uninitialized variable found."
