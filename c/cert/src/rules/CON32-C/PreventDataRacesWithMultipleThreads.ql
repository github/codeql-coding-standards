/**
 * @id c/cert/prevent-data-races-with-multiple-threads
 * @name CON32-C: Prevent data races when accessing bit-fields from multiple threads
 * @description Accesses to bit fields without proper concurrency protection can result in data
 *              races.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con32-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.guardaccesstobitfields.GuardAccessToBitFields

class PreventDataRacesWithMultipleThreadsQuery extends GuardAccessToBitFieldsSharedQuery {
  PreventDataRacesWithMultipleThreadsQuery() {
    this = Concurrency1Package::preventDataRacesWithMultipleThreadsQuery()
  }
}
