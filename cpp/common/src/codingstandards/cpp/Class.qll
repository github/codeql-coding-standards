/**
 * Provides a library with additional modeling for C++ Classes and related features.
 */

import cpp
import codingstandards.cpp.Expr

private Class getADerivedClass(Class c) {
  result = c.getADerivedClass()
  or
  exists(ClassTemplateInstantiation instantiation |
    instantiation.getADerivedClass() = result and c = instantiation.getTemplate()
  )
}

/**
 * A class that is used or intended to be used as a base class.
 */
class BaseClass extends Class {
  BaseClass() {
    exists(getADerivedClass(this))
    or
    this.isAbstract()
  }

  // We don't override `getADerivedClass` because that introduces a non-monotonic recursion.
  Class getASubClass() { result = getADerivedClass(this) }
}

/**
 * Gets a `FunctionDeclarationEntry` which is located within the declaration of the declaring type
 * of this member function.
 */
FunctionDeclarationEntry getDeclarationEntryInClassDeclaration(MemberFunction mf) {
  /*
   * This is more complicated than it should be, because declaration entries do not have logical
   * parent in the hierarchy, so it's impossible to determine directly whether the FDE is the one
   * declared in the body of the class.
   *
   * Instead, we leverage the fact that member functions cannot be declared outside the class body,
   * and so we can assume that any non-defined FDEs are declared in the class itself. If there are
   * no non-defined FDEs, then the FDE must be for the definition inside the class body.
   */

  result = mf.getADeclarationEntry() and
  // If there is at least one non-definition entry, then result must not be a definition
  (
    exists(FunctionDeclarationEntry fde | fde = mf.getADeclarationEntry() | not fde.isDefinition())
    implies
    not result.isDefinition()
  )
}

/** An implicitly added copy constructor. */
class ImplicitCopyConstructor extends CopyConstructor {
  ImplicitCopyConstructor() {
    // In this case the body is compiler generated
    (isCompilerGenerated() or isDefaulted()) and
    not isDeleted()
  }

  /** An implicit (see [class.copy]/15). */
  CopyConstructor getAnInferredCalledCopyConstructor() {
    result = getDeclaringType().getABaseClass().getAConstructor()
    or
    exists(Class c | c = getDeclaringType().getAField().getType().resolveTypedefs() |
      result = c.getAConstructor()
      or
      // As EDG has not added the call to this copy constructor explicitly, there is not a
      // copy constructor in the instantiation itself, so we will use the template class
      // copy constructor
      result = c.(ClassTemplateInstantiation).getTemplate().getAConstructor()
    )
  }
}

/**
 * A type that models an compiler-generated empty return statement.
 */
private class EmptyReturnStatement extends ReturnStmt {
  EmptyReturnStatement() { not hasExpr() }
}

/**
 * A type that models a special member function
 */
class SpecialMemberFunction extends Function {
  SpecialMemberFunction() {
    this instanceof CopyConstructor or
    this instanceof MoveConstructor or
    this instanceof CopyAssignmentOperator or
    this instanceof MoveAssignmentOperator or
    this instanceof Destructor or
    this instanceof Constructor
  }

  predicate hasVacuousBody() {
    exists(FunctionDeclarationEntry fde | fde = getDefinition() |
      fde.getFunction().getEntryPoint().(BlockStmt).getNumStmt() = 1 and
      fde.getFunction().getEntryPoint().(BlockStmt).getStmt(0) instanceof EmptyReturnStatement
    )
  }
}

/**
 * Type that models a non-defaulted special member function defined by a
 * user.
 */
class UserDefinedSpecialMemberFunction extends SpecialMemberFunction {
  UserDefinedSpecialMemberFunction() { not isCompilerGenerated() }
}

class TrivialAccessor extends MemberFunction {
  TrivialAccessor() {
    exists(ReturnStmt ret, MemberVariable mv |
      ret = this.getBlock().getStmt(0) and
      this.getBlock().getNumStmt() = 1 and
      this.getDeclaringType().getAMemberVariable() = mv
    |
      ret.getExpr() = mv.getAnAccess()
    )
  }
}

class TrivialMutator extends MemberFunction {
  TrivialMutator() {
    exists(AnyAssignExpr assign, Parameter param, MemberVariable mv |
      assign = this.getBlock().getStmt(0).(ExprStmt).getExpr() and
      this.getBlock().getStmt(1) instanceof EmptyReturnStatement and
      this.getBlock().getNumStmt() = 2 and
      param = this.getAParameter() and
      mv = this.getDeclaringType().getAMemberVariable()
    |
      assign.getLValue() = mv.getAnAccess() and
      assign.getRValue() = param.getAnAccess()
    )
  }
}

/**
 * Type that adds special introspection methods to member functions
 */
class IntrospectedMemberFunction extends MemberFunction {
  IntrospectedMemberFunction() { not isCompilerGenerated() }

  predicate hasVacuousBody() {
    this.getBlock().getNumStmt() = 1 and
    this.getBlock().getStmt(0) instanceof EmptyReturnStatement
  }

  predicate hasTrivialLength() {
    this.getBlock().getLocation().getEndLine() - this.getBlock().getLocation().getStartLine() <= 10
  }

  predicate isSetter() {
    getName().regexpMatch("(?i)^SET.*") and
    hasTrivialLength()
  }

  predicate isGetter() {
    getName().regexpMatch("(?i)^GET.*") and
    hasTrivialLength()
  }

  predicate isTrivialAccessor() { this instanceof TrivialAccessor }

  predicate isTrivialMutator() { this instanceof TrivialMutator }

  predicate isTriviallyInlined() {
    isTrivialAccessor()
    or
    isTrivialMutator()
  }
}

/**
 * Type that models a 'trivial' function according to the autosar definition.
 */
class TrivialMemberFunction extends IntrospectedMemberFunction {
  TrivialMemberFunction() {
    hasVacuousBody() or
    hasTrivialLength() or
    isGetter() or
    isSetter() or
    isTriviallyInlined()
  }
}

/**
 * Type that models a type that is either a template function or part of a templated
 * class.
 */
class TemplateOrTemplateClassMemberFunction extends MemberFunction {
  TemplateOrTemplateClassMemberFunction() {
    (
      isFromUninstantiatedTemplate(_) or
      isFromTemplateInstantiation(_)
    ) and
    not this.isCompilerGenerated()
  }
}

/**
 * Classes to model override and final member functions
 */
class OverrideFunction extends MemberFunction {
  OverrideFunction() { this.getASpecifier().hasName("override") }
}

class FinalFunction extends MemberFunction {
  FinalFunction() { this.getASpecifier().hasName("final") }
}
