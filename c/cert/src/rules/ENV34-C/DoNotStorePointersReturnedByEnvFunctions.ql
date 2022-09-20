/**
 * @id c/cert/do-not-store-pointers-returned-by-env-functions
 * @name ENV34-C: Do not store pointers returned by environment functions
 * @description The pointer returned by the Standard Library functions asctime, ctime, gmtime,
 *              localtime, localeconv, getenv, setlocale or strerror may be invalid following a
 *              subsequent call to the same function.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/env34-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.invalidatedenvstringpointers.InvalidatedEnvStringPointers

class DoNotStorePointersReturnedByEnvFunctionsQuery extends InvalidatedEnvStringPointersSharedQuery {
  DoNotStorePointersReturnedByEnvFunctionsQuery() {
    this = Contracts2Package::doNotStorePointersReturnedByEnvFunctionsQuery()
  }
}
