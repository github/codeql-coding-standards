/**
 * @id c/misra/call-to-setlocale-invalidates-old-pointers-warn
 * @name RULE-21-20: The pointer returned by the Standard Library env functions is invalid warning
 * @description The pointer returned by the Standard Library functions asctime, ctime, gmtime,
 *              localtime, localeconv, getenv, setlocale or strerror may be invalid following a
 *              subsequent call to the same function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-20
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.invalidatedenvstringpointerswarn.InvalidatedEnvStringPointersWarn

class CallToSetlocaleInvalidatesOldPointersWarnQuery extends InvalidatedEnvStringPointersWarnSharedQuery {
  CallToSetlocaleInvalidatesOldPointersWarnQuery() {
    this = Contracts2Package::callToSetlocaleInvalidatesOldPointersWarnQuery()
  }
}
