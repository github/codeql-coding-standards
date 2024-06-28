/**
 * @id cpp/misra/name-shall-be-referred-using-a-qualified-id-or-this-audit
 * @name RULE-6-4-3: (Audit) In a class template with a dependent base, any name that may be found in that dependent base shall shall be referred to using a qualified-id or this->
 * @description Not using a qualified-id or `this->` syntax for identifiers used in a class template
 *              makes the code more difficult to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-6-4-3
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.namenotreferredusingaqualifiedidorthisaudit_shared.NameNotReferredUsingAQualifiedIdOrThisAudit_shared

class NameShallBeReferredUsingAQualifiedIdOrThisAuditQuery extends NameNotReferredUsingAQualifiedIdOrThisAudit_sharedSharedQuery
{
  NameShallBeReferredUsingAQualifiedIdOrThisAuditQuery() {
    this = ImportMisra23Package::nameShallBeReferredUsingAQualifiedIdOrThisAuditQuery()
  }
}
