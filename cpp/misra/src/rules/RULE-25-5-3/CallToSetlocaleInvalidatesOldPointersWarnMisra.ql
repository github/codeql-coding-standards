/**
 * @id cpp/misra/call-to-setlocale-invalidates-old-pointers-warn-misra
 * @name RULE-25-5-3: The pointer returned by the Standard Library env functions is invalid warning
 * @description The pointer returned by the Standard Library functions asctime, ctime, gmtime,
 *              localtime, localeconv, getenv, setlocale or strerror may be invalid following a
 *              subsequent call to the same function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-25-5-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.invalidatedenvstringpointerswarn.InvalidatedEnvStringPointersWarn

class CallToSetlocaleInvalidatesOldPointersWarnMisraQuery extends InvalidatedEnvStringPointersWarnSharedQuery
{
  CallToSetlocaleInvalidatesOldPointersWarnMisraQuery() {
    this = ImportMisra23Package::callToSetlocaleInvalidatesOldPointersWarnMisraQuery()
  }
}
