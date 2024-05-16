/**
 * @id cpp/misra/call-to-setlocale-invalidates-old-pointers-misra
 * @name RULE-25-5-3: The pointer returned by the Standard Library env functions is invalid
 * @description The pointer returned by the Standard Library functions asctime, ctime, gmtime,
 *              localtime, localeconv, getenv, setlocale or strerror may be invalid following a
 *              subsequent call to the same function.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-25-5-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.invalidatedenvstringpointers.InvalidatedEnvStringPointers

class CallToSetlocaleInvalidatesOldPointersMisraQuery extends InvalidatedEnvStringPointersSharedQuery {
  CallToSetlocaleInvalidatesOldPointersMisraQuery() {
    this = ImportMisra23Package::callToSetlocaleInvalidatesOldPointersMisraQuery()
  }
}
