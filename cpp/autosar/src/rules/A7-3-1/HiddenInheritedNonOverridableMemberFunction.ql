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

from FunctionDeclarationEntry overridingDecl, FunctionDeclarationEntry hiddenDecl
where
  not isExcluded(overridingDecl, ScopePackage::hiddenInheritedNonOverridableMemberFunctionQuery()) and
  // Check if we are overriding a non-virtual inherited member function
  overridingDecl.getName() = hiddenDecl.getName() and
  overridingDecl.getDeclaration().getDeclaringType().getABaseClass() =
    hiddenDecl.getDeclaration().getDeclaringType() and
  not hiddenDecl.getDeclaration().isVirtual() and
  // Where the hidden member function isn't explicitly brought in scope through a using declaration.
  not exists(UsingDeclarationEntry ude |
    ude.getDeclaration() = hiddenDecl.getDeclaration() and
    ude.getEnclosingElement() = overridingDecl.getDeclaration().getDeclaringType() and
    ude.getLocation().getStartLine() < overridingDecl.getLocation().getStartLine()
  ) and
  // Exclude compiler generated member functions which include things like copy constructor that hide base class
  // copy constructors.
  not overridingDecl.getDeclaration().isCompilerGenerated()
select overridingDecl,
  "Declaration for member '" + overridingDecl.getName() +
    "' hides non-overridable inherited member function $@", hiddenDecl, hiddenDecl.getName()
