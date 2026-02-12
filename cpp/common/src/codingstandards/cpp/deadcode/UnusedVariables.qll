import cpp
import codingstandards.cpp.FunctionEquivalence
import codingstandards.cpp.Scope

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

predicate hasAttrUnused(Variable v) {
  v.getAnAttribute().hasName(["unused", "used", "maybe_unused", "cleanup"])
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

/**
 * This module defines unused variables as defined by all standards, including MISRA C, C++, and
 * AUTOSAR.
 *
 * This pass excludes variables that can be implicitly used in many ways. It notably does not
 * exclude variables that are used in macros, which MISRA C supports specially.
 */
module FirstPassUnused {
  final private class FinalLocalVariable = LocalVariable;

  final private class FinalGlobalOrNspVariable = GlobalOrNamespaceVariable;

  /**
   * A `LocalVariable` which is a candidate for being unused, and may or may not be defined in a macro.
   */
  class UnusedLocalVariable extends FinalLocalVariable {
    UnusedLocalVariable() {
      not exists(getAnAccess()) and
      // Ignore variables where initializing the variable has side effects
      not declarationHasSideEffects(this) and // TODO non POD types with initializers? Also, do something different with templates?
      exists(Function f | f = getFunction() |
        // Ignore functions with assembly, as the assembly may use the variable
        not exists(AsmStmt s | f = s.getEnclosingFunction()) and
        // Ignore functions with error expressions as they indicate expressions that the extractor couldn't process
        not any(ErrorExpr e).getEnclosingFunction() = f
      ) and
      // exclude uninstantiated template members
      not this.isFromUninstantiatedTemplate(_) and
      // Do not report compiler generated variables
      not this.isCompilerGenerated()
    }
  }

  /** A `GlobalOrNamespaceVariable` which is potentially unused and may or may not be defined in a macro */
  class UnusedGlobalOrNamespaceVariable extends FinalGlobalOrNspVariable {
    UnusedGlobalOrNamespaceVariable() {
      not exists(getAnAccess()) and
      // A non-defined variable may never be used
      hasDefinition() and
      // No side-effects from declaration
      not declarationHasSideEffects(this) and
      // exclude uninstantiated template members
      not this.isFromUninstantiatedTemplate(_) and
      // Do not report compiler generated variables
      not this.isCompilerGenerated()
    }
  }
}

/**
 * This module defines an intermediate conservative pass for filtering out unused variables.
 *
 * This pass filters out variables defined in macros, and is used by AUTOSAR and MISRA, before a
 * more expensive third pass.
 */
module SecondPassUnused {
  final private class FirstPassLocalVariable = FirstPassUnused::UnusedLocalVariable;

  final private class FirstPassGlobalOrNspVariable =
    FirstPassUnused::UnusedGlobalOrNamespaceVariable;

  final private class FinalMemberVariable = MemberVariable;

  /**
   * A `LocalVariable` which is a candidate for being unused, and not defined in a macro.
   */
  class UnusedLocalVariable extends FirstPassLocalVariable {
    UnusedLocalVariable() {
      // Ignore variables declared in macro expansions
      not exists(DeclStmt ds | ds.getADeclaration() = this and ds.isInMacroExpansion())
    }
  }

  /** A `MemberVariable` which is potentially unused. */
  class UnusedMemberVariable extends FinalMemberVariable {
    UnusedMemberVariable() {
      not exists(getAnAccess()) and
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
      not this = any(LambdaCapture lc).getField() and
      // exclude uninstantiated template members
      not this.isFromUninstantiatedTemplate(_) and
      // Do not report compiler generated variables
      not this.isCompilerGenerated()
    }
  }

  /**
   * A `GlobalOrNamespaceVariable` which is potentially unused, and is not defined in a macro.
   */
  class UnusedGlobalOrNamespaceVariable extends FirstPassGlobalOrNspVariable {
    UnusedGlobalOrNamespaceVariable() {
      // Not declared in a macro expansion
      not isInMacroExpansion()
    }
  }
}

predicate isUnused(Variable variable) {
  not exists(variable.getAnAccess()) and
  variable.getInitializer().fromSource()
}

/**
 * This module is the final pass for unused variables in AUTOSAR, and an intermediate pass for MISRA.
 *
 * This pass looks for odd cases such as constexpr variables whose usage was inlined by the compiler
 * and therefore not visible to us.
 */
module ThirdPassUnused {
  class UserProvidedConstructorFieldInit extends ConstructorFieldInit {
    UserProvidedConstructorFieldInit() {
      not isCompilerGenerated() and
      not getEnclosingFunction().isCompilerGenerated()
    }
  }

  /**
   * Holds if `v` may hold a compile time value and is accessible to a template instantiation that
   * receives a constant value as an argument equal to the value of `v`.
   */
  predicate maybeACompileTimeTemplateArgument(Variable v) {
    v.isConstexpr() and
    exists(ClassTemplateInstantiation cti, TranslationUnit tu |
      cti.getATemplateArgument().(Expr).getValue() = v.getInitializer().getExpr().getValue() and
      (
        cti.getFile() = tu and
        (
          v.getADeclarationEntry().getFile() = tu or
          tu.getATransitivelyIncludedFile() = v.getADeclarationEntry().getFile()
        )
      )
    )
  }

  /** Gets the constant value of a constexpr/const variable. */
  string getConstExprValue(Variable v) {
    result = v.getInitializer().getExpr().getValue() and
    (v.isConst() or v.isConstexpr())
  }

  /**
   * Counts uses of `Variable` v in a local array of size `n`
   */
  int countUsesInLocalArraySize(Variable v) {
    result =
      count(ArrayType at, LocalVariable arrayVariable |
        arrayVariable.getType().resolveTypedefs() = at and
        v.(SecondPassUnused::UnusedLocalVariable).getFunction() = arrayVariable.getFunction() and
        at.getArraySize().toString() = getConstExprValue(v)
      )
  }

  // Collect constant values that we should use to exclude otherwise unused constexpr variables.
  //
  // For constexpr variables used as template arguments or in static_asserts, we don't see accesses
  // (just the appropriate literals). We therefore take a conservative approach and do not report
  // constexpr variables whose values are used in such contexts.
  //
  // For performance reasons, these special values should be collected in a single pass.
  predicate excludedConstantValue(string value) {
    value = any(ClassTemplateInstantiation cti).getTemplateArgument(_).(Expr).getValue()
    or
    value = any(StaticAssert sa).getCondition().getAChild*().getValue()
  }

  /**
   * Defines the local variables that should be excluded from the unused variable analysis based
   * on their constant value.
   *
   * See `excludedConstantValue` for more details.
   */
  predicate excludeVariableByValue(Variable variable) {
    variable.isConstexpr() and
    excludedConstantValue(getConstExprValue(variable))
  }

  // TODO: This predicate may be possible to merge with M0-1-4's getUseCount(). These two rules
  // diverged to handle `excludeVariableByValue`, but may be possible to merge.
  int getUseCountConservatively(Variable v) {
    result =
      count(VariableAccess access | access = v.getAnAccess()) +
        count(UserProvidedConstructorFieldInit cfi | cfi.getTarget() = v) +
        // In case an array type uses a constant in the same scope as the constexpr variable,
        // consider it as used.
        countUsesInLocalArraySize(v)
  }

  predicate isConservativelyUnused(Variable v) {
    getUseCountConservatively(v) = 0 and
    not excludeVariableByValue(v)
  }

  final class SecondPassLocalVariable = SecondPassUnused::UnusedLocalVariable;

  final class SecondPassGlobalOrNspVariable = SecondPassUnused::UnusedGlobalOrNamespaceVariable;

  final class SecondPassMemberVariable = SecondPassUnused::UnusedMemberVariable;

  class UnusedLocalVariable extends SecondPassLocalVariable {
    UnusedLocalVariable() {
      // Sometimes multiple objects representing the same entities are created in
      // the AST. Check if those are not accessed as well. Refer issue #658
      not exists(LocalScopeVariable another |
        another.getDefinitionLocation() = this.getDefinitionLocation() and
        another.hasName(this.getName()) and
        exists(another.getAnAccess()) and
        another != this
      ) and
      isConservativelyUnused(this)
    }
  }

  class UnusedGlobalOrNamespaceVariable extends SecondPassGlobalOrNspVariable {
    UnusedGlobalOrNamespaceVariable() {
      // Exclude members whose value is compile time and is potentially used to inintialize a template
      not maybeACompileTimeTemplateArgument(this)
    }
  }

  class UnusedMemberVariable extends SecondPassMemberVariable {
    UnusedMemberVariable() {
      // No explicit initialization in a constructor
      not exists(UserProvidedConstructorFieldInit cfi | cfi.getTarget() = this) and
      // Exclude members whose value is compile time and is potentially used to inintialize a template
      not maybeACompileTimeTemplateArgument(this)
    }
  }
}
