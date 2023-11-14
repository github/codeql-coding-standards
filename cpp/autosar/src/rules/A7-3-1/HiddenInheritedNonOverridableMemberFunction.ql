/**
 * @id cpp/autosar/hidden-inherited-non-overridable-member-function
 * @name A7-3-1: Member function hides inherited member function
 * @description A non-overriding member function definition that hides an inherited member function
 *              can result in unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class

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

from MemberFunction overridingDecl, MemberFunction hiddenDecl, Class baseClass, string name
where
  not isExcluded(overridingDecl, ScopePackage::hiddenInheritedNonOverridableMemberFunctionQuery()) and
  // Check if we are overriding a non-virtual inherited member function
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
  not overridingDecl instanceof SpecialMemberFunction
select overridingDecl,
  "Declaration for member '" + name + "' hides non-overridable inherited member function $@",
  hiddenDecl, hiddenDecl.getName()
