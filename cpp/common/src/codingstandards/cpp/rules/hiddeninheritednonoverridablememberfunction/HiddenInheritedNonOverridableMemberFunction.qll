/**
 * Provides a library with a `problems` predicate for the following issue:
 * A non-overriding member function definition that hides an inherited member function
 * can result in unexpected behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Class

abstract class HiddenInheritedNonOverridableMemberFunctionSharedQuery extends Query { }

Query getQuery() { result instanceof HiddenInheritedNonOverridableMemberFunctionSharedQuery }

/**
 * Holds if the class has a non-virtual member function with the given name.
 */
pragma[noinline, nomagic]
predicate hasNonVirtualMemberFunction(Class clazz, MemberFunction mf, string name) {
  mf.getDeclaringType() = clazz and
  mf.getName() = name and
  not mf.isVirtual() and
  // Exclude private member functions, which cannot be inherited.
  not mf.isPrivate()
}

/**
 * Holds if the member function is in a class with the given base class, and has the given name.
 */
pragma[noinline, nomagic]
predicate hasDeclarationBaseClass(MemberFunction mf, Class baseClass, string functionName) {
  baseClass = mf.getDeclaringType().getABaseClass() and
  functionName = mf.getName()
}

query predicate problems(
  MemberFunction overridingDecl, string message, MemberFunction hiddenDecl, string hiddenDecl_string
) {
  exists(Class baseClass, string name |
    not isExcluded(overridingDecl, getQuery()) and // Check if we are overriding a non-virtual inherited member function
    hasNonVirtualMemberFunction(baseClass, hiddenDecl, name) and
    hasDeclarationBaseClass(overridingDecl, baseClass, name) and
    // Where the hidden member function isn't explicitly brought in scope through a using declaration.
    not exists(UsingDeclarationEntry ude |
      ude.getDeclaration() = hiddenDecl and
      ude.getEnclosingElement() = overridingDecl.getDeclaringType()
    ) and
    // Exclude compiler generated member functions which include things like copy constructor that hide base class
    // copy constructors.
    not overridingDecl.isCompilerGenerated() and
    // Exclude special member functions, which cannot be inherited.
    not overridingDecl instanceof SpecialMemberFunction and
    message =
      "Declaration for member '" + name + "' hides non-overridable inherited member function $@" and
    hiddenDecl_string = hiddenDecl.getName()
  )
}
