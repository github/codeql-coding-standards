/**
 * @id c/cert/do-not-store-pointers-returned-by-environment-fun-warn
 * @name ENV34-C: Do not store pointers returned by environment functions warning
 * @description The pointer returned by the Standard Library functions asctime, ctime, gmtime,
 *              localtime, localeconv, getenv, setlocale or strerror may be invalid following a
 *              subsequent call to the same function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/env34-c
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.invalidatedenvstringpointerswarn.InvalidatedEnvStringPointersWarn

class DoNotStorePointersReturnedByEnvironmentFunWarnQuery extends InvalidatedEnvStringPointersWarnSharedQuery
{
  DoNotStorePointersReturnedByEnvironmentFunWarnQuery() {
    this = Contracts2Package::doNotStorePointersReturnedByEnvironmentFunWarnQuery()
  }
}
