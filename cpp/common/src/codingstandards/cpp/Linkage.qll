/**
 * A module to reason about the linkage of objects and functions.
 */

import cpp
import codingstandards.cpp.Scope

/**
 * [basic]/6 uses a specific definition of "variable" that excludes non-static data members.
 */
private predicate isSpecificationVariable(Variable v) {
  v.(MemberVariable).isStatic()
  or
  not v instanceof MemberVariable
}

/** Holds if `elem` has internal linkage. */
predicate hasInternalLinkage(Element elem) {
  // An unnamed namespace or a namespace declared directly or indirectly within an unnamed namespace has internal linkage
  directlyOrIndirectlyUnnnamedNamespace(elem)
  or
  exists(Declaration decl | decl = elem |
    // A name having namespace scope has internal linkage if it is the name of
    hasNamespaceScope(decl) and
    (
      // a variable, function or function template
      (
        isSpecificationVariable(decl)
        or
        decl instanceof Function // TemplateFunction is a subclass of Function so this captures both.
      ) and
      // that is explicitly declared static; or,
      decl.isStatic()
      or
      // a non-volatile variable
      isSpecificationVariable(decl) and
      not decl.(Variable).isVolatile() and
      // that is explicitly declared const or constexpr and
      (decl.(Variable).isConst() or decl.(Variable).isConstexpr()) and
      // neither explicitly declared external nor previously declared to have external linkage; or
      not exists(DeclarationEntry e | e = decl.getADeclarationEntry() | e.hasSpecifier("extern"))
      or
      // a data member of an anonymous union.
      exists(Union u | hasNamespaceScope(u) and u.isAnonymous() |
        decl = u.getACanonicalMemberVariable()
      )
    )
    or
    directlyOrIndirectlyUnnnamedNamespace(decl.getNamespace()) and
    inheritsLinkageOfNamespace(decl.getNamespace(), decl)
    or
    exists(Class klass |
      hasInternalLinkage(klass) and
      inheritsLinkageOfClass(klass, decl)
    )
  )
}

/** Holds if `elem` has external linkage. */
predicate hasExternalLinkage(Element elem) {
  elem instanceof Namespace and
  not directlyOrIndirectlyUnnnamedNamespace(elem)
  or
  not hasInternalLinkage(elem) and
  exists(Declaration decl | decl = elem |
    // A name having namespace scope that has not been given internal linkage above has the same linkage as the enclosing namespace if it is the name of
    not directlyOrIndirectlyUnnnamedNamespace(decl.getNamespace()) and
    inheritsLinkageOfNamespace(decl.getNamespace(), decl)
    or
    exists(Class klass |
      hasExternalLinkage(klass) and
      inheritsLinkageOfClass(klass, decl)
    )
  )
}

private predicate directlyOrIndirectlyUnnnamedNamespace(Namespace ns) {
  exists(Namespace anonymous |
    anonymous.isAnonymous() and
    ns = anonymous.getAChildNamespace*()
  )
}

private predicate hasLinkageOfTypedef(TypedefType typedef, Element decl) {
  // an unnamed class defined in a typedef declartion in which the class has the typedef name for linkage purposes
  decl.(Class).isAnonymous() and typedef.getADeclaration() = decl
  or
  // an unnamed enumeration defined in a typedef declaration in which the enumeration has the typedef name for linkage purposes
  decl.(Enum).isAnonymous() and typedef.getADeclaration() = decl
}

private predicate inheritsLinkageOfNamespace(Namespace ns, Declaration decl) {
  hasNamespaceScope(decl) and
  ns = decl.getNamespace() and
  (
    // A name having namespace scope that has not been given internal linkage above has the same linkage as the enclosing namespace if it is the name of
    // a variable;
    isSpecificationVariable(decl)
    or
    // a function
    decl instanceof Function
    or
    decl instanceof Class and not decl.(Class).isAnonymous() // a named class
    or
    decl instanceof Enum and not decl.(Enum).isAnonymous() // a named enumeration
    or
    // a template
    decl instanceof TemplateClass
    or
    decl instanceof TemplateFunction
    or
    decl instanceof TemplateVariable
  )
  or
  hasNamespaceScope(decl) and
  exists(TypedefType typedef | hasLinkageOfTypedef(typedef, decl) and ns = typedef.getNamespace())
}

private predicate inheritsLinkageOfClass(Class klass, Element decl) {
  hasClassScope(decl) and
  (
    // a member function,
    decl.(MemberFunction).getDeclaringType() = klass
    or
    // static data member
    decl.(MemberVariable).isStatic() and decl.(MemberVariable).getDeclaringType() = klass
    or
    decl.(Class).getDeclaringType() = klass and not decl.(Class).isAnonymous()
    or
    decl.(Enum).getDeclaringType() = klass and not decl.(Enum).isAnonymous()
    or
    exists(TypedefType typedef |
      hasLinkageOfTypedef(typedef, decl) and klass = typedef.getDeclaringType()
    )
  )
}
