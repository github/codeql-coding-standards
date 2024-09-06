/**
 * Provides a library with a `problems` predicate for the following issue:
 * An overriding member function definition thats hides an overload of the overridden
 * inherited member function can result in unexpected behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class HiddenInheritedOverridableMemberFunctionSharedQuery extends Query { }

Query getQuery() { result instanceof HiddenInheritedOverridableMemberFunctionSharedQuery }

query predicate problems(
  FunctionDeclarationEntry overridingDecl, string message, FunctionDeclarationEntry hiddenDecl,
  string hiddenDecl_string
) {
  not isExcluded(overridingDecl, getQuery()) and
  // Check if we are overriding a virtual inherited member function
  hiddenDecl.getDeclaration().isVirtual() and
  // Exclude private member functions, which cannot be inherited.
  not hiddenDecl.getDeclaration().(MemberFunction).isPrivate() and
  // The overriding declaration hides the hidden declaration if:
  (
    // 1. the overriding declaration overrides a function in a base class that is an overload of the hidden declaration
    // and the hidden declaration isn't overriden in the same class.
    exists(FunctionDeclarationEntry overridenDecl |
      overridingDecl.getDeclaration().(MemberFunction).overrides(overridenDecl.getDeclaration()) and
      overridenDecl.getDeclaration().getAnOverload() = hiddenDecl.getDeclaration() and
      not exists(MemberFunction overridingFunc |
        hiddenDecl.getDeclaration().(MemberFunction).getAnOverridingFunction() = overridingFunc and
        overridingFunc.getDeclaringType() = overridingDecl.getDeclaration().getDeclaringType()
      )
    ) and
    // and the hidden declaration isn't explicitly brought in scope through a using declaration.
    not exists(UsingDeclarationEntry ude |
      ude.getDeclaration() = hiddenDecl.getDeclaration() and
      ude.getEnclosingElement() = overridingDecl.getDeclaration().getDeclaringType()
    )
    or
    // 2. if the overriding declaration doesn't override a base member function but has the same name
    // as the hidden declaration
    not overridingDecl.getDeclaration().(MemberFunction).overrides(_) and
    overridingDecl.getName() = hiddenDecl.getName() and
    overridingDecl.getDeclaration().getDeclaringType().getABaseClass() =
      hiddenDecl.getDeclaration().getDeclaringType()
  ) and
  // Limit the results to the declarations and not the definitions, if any.
  (overridingDecl.getDeclaration().hasDefinition() implies not overridingDecl.isDefinition()) and
  (hiddenDecl.getDeclaration().hasDefinition() implies not hiddenDecl.isDefinition()) and
  message =
    "Declaration for member '" + overridingDecl.getName() +
      "' hides overridable inherited member function $@" and
  hiddenDecl_string = hiddenDecl.getName()
}
