/**
 * Provides a library with a `problems` predicate for the following issue:
 * Not using a qualified-id or `this->` syntax for identifiers used in a class template
 * makes the code more difficult to understand.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.NameInDependentBase

abstract class NameNotReferredUsingAQualifiedIdOrThisAuditSharedQuery extends Query { }

Query getQuery() { result instanceof NameNotReferredUsingAQualifiedIdOrThisAuditSharedQuery }

query predicate problems(
  NameQualifiableElement fn, string message, Element actualTarget, string targetName,
  Element dependentTypeMemberWithSameName, string dependentType_string
) {
  not isExcluded(fn, getQuery()) and
  not isCustomExcluded(fn) and
  missingNameQualifier(fn) and
  exists(TemplateClass c |
    fn = getConfusingFunctionAccess(c, targetName, actualTarget, dependentTypeMemberWithSameName)
    or
    fn = getConfusingFunctionCall(c, targetName, actualTarget, dependentTypeMemberWithSameName) and
    not exists(Expr e | e = fn.(FunctionCall).getQualifier())
    or
    not fn.(VariableAccess).getTarget() instanceof Parameter and
    fn =
      getConfusingMemberVariableAccess(c, targetName, actualTarget, dependentTypeMemberWithSameName) and
    not exists(Expr e | e = fn.(VariableAccess).getQualifier())
  ) and
  message =
    "Use of unqualified identifier " + targetName +
      " targets $@ but a member with the name also exists $@." and
  dependentType_string = "in the dependent base class"
}
