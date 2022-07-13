/**
 * A module to reason about the linkage of objects and functions.
 */

import cpp
import codingstandards.cpp.Scope

/** Holds if `elem` has internal linkage. */
predicate hasInternalLinkage(Element elem) {
  exists(Declaration decl | decl = elem |
    // A name having namespace scope has internal linkage if it is the name of
    hasNamespaceScope(decl) and
    (
      // a variable, function or function template
      (
        decl instanceof Variable
        or
        decl instanceof Function // TemplateFunction is a subclass of Function so this captures both.
      ) and
      // that is explicitly declared static; or,
      decl.isStatic()
      or
      // a non-volatile variable
      decl instanceof Variable and
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
      or
      // A name having namespace scope that has not been given internal linkage above has the same linkage as the enclosing namespace if it is the name of
      hasInternalLinkage(decl.getNamespace()) and
      (
        // a variable;
        decl instanceof Variable
        or
        // a function
        decl instanceof Function
        or
        // a named class, or an unnamed class defined in a typedef declartion in which the class has the typedef name for linkage purposes
        exists(Class klass | decl = klass |
          not klass.isAnonymous()
          or
          klass.isAnonymous() and exists(TypedefType typedef | typedef.getADeclaration() = klass)
        )
        or
        // a named enumeration, or an unnamed enumeration defined in a typedef declaration in which the enumeration has the typedef name for linkage purposes
        exists(Enum enum | enum = decl |
          not enum.isAnonymous()
          or
          enum.isAnonymous() and exists(TypedefType typedef | typedef.getADeclaration() = enum)
        )
        or
        // an enumerator beloning to an enumeration with linkage
        exists(Enum enum | enum.getADeclaration() = decl | hasInternalLinkage(enum))
        or
        // a template
        decl instanceof TemplateClass
        or
        decl instanceof TemplateFunction
      )
    )
    or
    decl instanceof GlobalVariable and
    (
      decl.(GlobalVariable).isStatic() or
      decl.(GlobalVariable).isConst()
    ) and
    not decl.(GlobalVariable).hasSpecifier("external")
  )
  or
  // An unnamed namespace or a namespace declared directly or indirectly within an unnamed namespace has internal linkage
  exists(Namespace ns | ns = elem |
    ns.isAnonymous()
    or
    not ns.isAnonymous() and
    exists(Namespace parent | parent.isAnonymous() and parent.getAChildNamespace+() = ns)
  )
  or
  elem instanceof TopLevelFunction and
  elem.(Function).isStatic()
}

/** Holds if `elem` has external linkage. */
predicate hasExternalLinkage(Element elem) {
  not hasInternalLinkage(elem) and
  (
    exists(Declaration decl | decl = elem |
      hasNamespaceScope(decl) and
      // A name having namespace scope that has not been given internal linkage above has the same linkage as the enclosing namespace if it is the name of
      not hasInternalLinkage(decl.getNamespace()) and
      (
        // a variable;
        decl instanceof Variable
        or
        // a function
        decl instanceof Function
        or
        // a named class, or an unnamed class defined in a typedef declaration in which the class has the typedef name for linkage purposes
        exists(Class klass | decl = klass |
          not klass.isAnonymous()
          or
          klass.isAnonymous() and exists(TypedefType typedef | typedef.getADeclaration() = klass)
        )
        or
        // a named enumeration, or an unnamed enumeration defined in a typedef declaration in which the enumeration has the typedef name for linkage purposes
        exists(Enum enum | enum = decl |
          not enum.isAnonymous()
          or
          enum.isAnonymous() and exists(TypedefType typedef | typedef.getADeclaration() = enum)
        )
        or
        // an enumerator beloning to an enumeration with linkage
        exists(Enum enum | enum.getADeclaration() = decl | hasInternalLinkage(enum))
        or
        // a template
        decl instanceof TemplateClass
        or
        decl instanceof TemplateFunction
      )
      or
      // In addition,
      hasClassScope(decl) and
      (
        // a member function,
        decl instanceof MemberFunction
        or
        // static data member
        decl instanceof MemberVariable and decl.(MemberVariable).isStatic()
        or
        // a named class, or an unnamed class defined in a typedef declartion in which the class has the typedef name for linkage purposes
        exists(Class klass | decl = klass |
          not klass.isAnonymous()
          or
          klass.isAnonymous() and exists(TypedefType typedef | typedef.getADeclaration() = klass)
        )
        or
        // a named enumeration, or an unnamed enumeration defined in a typedef declaration in which the enumeration has the typedef name for linkage purposes
        exists(Enum enum | enum = decl |
          not enum.isAnonymous()
          or
          enum.isAnonymous() and exists(TypedefType typedef | typedef.getADeclaration() = enum)
        )
      ) and
      // has external linkage if the name of the class has external linkage
      hasExternalLinkage(decl.getDeclaringType())
      or
      decl instanceof GlobalVariable and
      not decl.(GlobalVariable).isStatic() and
      not decl.(GlobalVariable).isConst()
    )
    or
    elem instanceof Namespace
    or
    elem instanceof TopLevelFunction
  )
}
