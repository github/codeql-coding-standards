/**
 * @id c/misra/unsequenced-side-effects
 * @name RULE-13-2: The value of an expression and its persistent side effects depend on its evaluation order
 * @description The value of an expression and its persistent side effects are depending on the
 *              evaluation order resulting in unpredictable behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-13-2
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.memoryoperationsnotsequencedappropriately.MemoryOperationsNotSequencedAppropriately

class UnsequencedSideEffectsQuery extends MemoryOperationsNotSequencedAppropriatelySharedQuery
{
  UnsequencedSideEffectsQuery() { this = SideEffects3Package::unsequencedSideEffectsQuery() }
}
