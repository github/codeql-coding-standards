/**
 * @id cpp/autosar/name-not-referred-using-a-qualified-id-or-this-audit
 * @name M14-6-1: (Audit) In a class template with a dependent base, any name that may be found in that dependent base shall shall be referred to using a qualified-id or this->
 * @description Not using a qualified-id or `this->` syntax for identifiers used in a class template
 *              makes the code more difficult to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m14-6-1
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.namenotreferredusingaqualifiedidorthisaudit_shared.NameNotReferredUsingAQualifiedIdOrThisAudit_shared

class NameNotReferredUsingAQualifiedIdOrThisAuditQuery extends NameNotReferredUsingAQualifiedIdOrThisAudit_sharedSharedQuery
{
  NameNotReferredUsingAQualifiedIdOrThisAuditQuery() {
    this = TemplatesPackage::nameNotReferredUsingAQualifiedIdOrThisAuditQuery()
  }
}
