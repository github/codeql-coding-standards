/**
 * @id cpp/misra/memory-operations-not-sequenced-appropriately
 * @name RULE-4-6-1: Operations on a memory location shall be sequenced appropriately
 * @description Operations on a memory location shall be sequenced appropriately.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-4-6-1
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.memoryoperationsnotsequencedappropriately.MemoryOperationsNotSequencedAppropriately

class MemoryOperationsNotSequencedAppropriatelyQuery extends MemoryOperationsNotSequencedAppropriatelySharedQuery
{
  MemoryOperationsNotSequencedAppropriatelyQuery() {
    this = ImportMisra23Package::memoryOperationsNotSequencedAppropriatelyQuery()
  }
}
