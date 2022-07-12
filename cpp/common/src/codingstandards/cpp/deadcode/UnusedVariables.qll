import cpp
import codingstandards.cpp.FunctionEquivalence

/**
 * A type that contains a template parameter type (doesn't count pointers or references).
 *
 * These types may have a constructor / destructor when they are instantiated, that is not visible
 * in their template form.
 *
 * Such types include template parameters, classes with a member variable of template parameter
 * type, and classes that derive from other such* classes.
 */
class TemplateDependentType extends Type {
  TemplateDependentType() {
    this instanceof TemplateParameter
    or
    exists(TemplateDependentType t |
      this.refersToDirectly(t) and
      not this instanceof PointerType and
      not this instanceof ReferenceType
    )
  }
}

/**
 * A variable whose declaration has, or may have, side effects.
 */
predicate declarationHasSideEffects(Variable v) {
  exists(Class c | c = v.getUnspecifiedType() |
    c.hasConstructor() or
    c.hasDestructor()
  )
  or
  // A template dependent type is "incomplete"
  v.getType() instanceof TemplateDependentType
}

/** A `LocalVariable` which is a candidate for being unused. */
class PotentiallyUnusedLocalVariable extends LocalVariable {
  PotentiallyUnusedLocalVariable() {
    // Ignore variables declared in macro expansions
    not exists(DeclStmt ds | ds.getADeclaration() = this and ds.isInMacroExpansion()) and
    // Ignore variables where initializing the variable has side effects
    not declarationHasSideEffects(this) and // TODO non POD types with initializers? Also, do something different with templates?
    exists(Function f | f = getFunction() |
      // Ignore functions with assembly, as the assembly may use the variable
      not exists(AsmStmt s | f = s.getEnclosingFunction()) and
      // Ignore functions with error expressions as they indicate expressions that the extractor couldn't process
      not any(ErrorExpr e).getEnclosingFunction() = f
    )
  }
}

/** Holds if `mf` is "defined" in this database. */
predicate isDefined(MemberFunction mf) {
  exists(MemberFunction definedMemberFunction |
    // The member function may be defined in another translation unit
    definedMemberFunction = getAnEquivalentFunction(mf)
  |
    definedMemberFunction.hasDefinition()
    or
    // A PureVirtualFunction is "defined" for our purposes
    definedMemberFunction instanceof PureVirtualFunction
  )
}

/** A `Class` where all non compiler generated member functions are defined in the current database. */
class FullyDefinedClass extends Class {
  FullyDefinedClass() {
    // All member functions which are not compiler generated should be defined
    forall(MemberFunction mf |
      mf = getAMemberFunction() and
      // Not a compiler generated
      not mf.isCompilerGenerated()
    |
      isDefined(mf)
    )
  }
}

/** A `MemberVariable` which is potentially unused. */
class PotentiallyUnusedMemberVariable extends MemberVariable {
  PotentiallyUnusedMemberVariable() {
    // Not an unnamed bitfield, which is permitted to be unused
    not getName() = "(unnamed bitfield)" and
    // Must be defined in this database
    hasDefinition() and
    // Declaration is not affected by a macro
    not getADeclarationEntry().isAffectedByMacro() and
    // No side effects from instantiating the class TODO is this right?! - I think this will exclude non-template arguments
    not declarationHasSideEffects(this) and
    // Must be in a fully defined class, otherwise one of the undefined functions may use the variable
    getDeclaringType() instanceof FullyDefinedClass and
    // Lambda captures are not "real" member variables - it's an implementation detail that they are represented that way
    not this = any(LambdaCapture lc).getField()
  }
}

/** A `GlobalOrNamespaceVariable` which is potentially unused. */
class PotentiallyUnusedGlobalOrNamespaceVariable extends GlobalOrNamespaceVariable {
  PotentiallyUnusedGlobalOrNamespaceVariable() {
    // A non-defined variable may never be used
    hasDefinition() and
    // Not declared in a macro expansion
    not isInMacroExpansion() and
    // No side-effects from declaration
    not declarationHasSideEffects(this)
  }
}

predicate isUnused(Variable variable) {
  not exists(variable.getAnAccess()) and
  variable.getInitializer().fromSource()
}

class UserProvidedConstructorFieldInit extends ConstructorFieldInit {
  UserProvidedConstructorFieldInit() {
    not isCompilerGenerated() and
    not getEnclosingFunction().isCompilerGenerated()
  }
}
