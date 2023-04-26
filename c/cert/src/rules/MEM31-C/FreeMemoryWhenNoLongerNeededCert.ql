/**
 * @id c/cert/free-memory-when-no-longer-needed-cert
 * @name MEM31-C: Free dynamically allocated memory when no longer needed
 * @description Failing to free memory that is no longer needed can lead to a memory leak and
 *              resource exhaustion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/mem31-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.freememorywhennolongerneededshared.FreeMemoryWhenNoLongerNeededShared

class FreeMemoryWhenNoLongerNeededCertQuery extends FreeMemoryWhenNoLongerNeededSharedSharedQuery {
  FreeMemoryWhenNoLongerNeededCertQuery() {
    this = Memory2Package::freeMemoryWhenNoLongerNeededCertQuery()
  }
}
