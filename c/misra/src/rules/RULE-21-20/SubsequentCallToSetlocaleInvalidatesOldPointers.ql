/**
 * @id c/misra/subsequent-call-to-setlocale-invalidates-old-pointers
 * @name RULE-21-20: The pointer returned by the Standard Library functions asctime, ctime, gmtime, localtime,
 * @description The pointer returned by the Standard Library functions asctime, ctime, gmtime,
 *              localtime, localeconv, getenv, setlocale or strerror may be invalid following a
 *              subsequent call to the same function.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-20
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.invalidatedenvstringpointers.InvalidatedEnvStringPointers

class SubsequentCallToSetlocaleInvalidatesOldPointersQuery extends InvalidatedEnvStringPointersSharedQuery {
  SubsequentCallToSetlocaleInvalidatesOldPointersQuery() {
    this = Contracts2Package::subsequentCallToSetlocaleInvalidatesOldPointersQuery()
  }
}
