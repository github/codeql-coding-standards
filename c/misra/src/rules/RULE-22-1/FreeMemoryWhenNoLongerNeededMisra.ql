/**
 * @id c/misra/free-memory-when-no-longer-needed-misra
 * @name RULE-22-1: Memory allocated dynamically with Standard Library functions shall be explicitly released
 * @description Memory allocated dynamically with standard library functions should be freed to
 *              avoid memory leaks.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-1
 *       correctness
 *       security
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.freememorywhennolongerneededshared.FreeMemoryWhenNoLongerNeededShared

class FreeMemoryWhenNoLongerNeededMisraQuery extends FreeMemoryWhenNoLongerNeededSharedSharedQuery {
  FreeMemoryWhenNoLongerNeededMisraQuery() {
    this = Memory2Package::freeMemoryWhenNoLongerNeededMisraQuery()
  }
}
