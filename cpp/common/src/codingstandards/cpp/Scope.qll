/**
 * A module to reason about the scope of elements.
 */

import cpp
import codingstandards.cpp.ConstHelpers

/**
 * a `Variable` that is nonvolatile and const
 * and of type `IntegralOrEnumType`
 */
class NonVolatileConstIntegralOrEnumVariable extends Variable {
  NonVolatileConstIntegralOrEnumVariable() {
    not this.isVolatile() and
    this.isConst() and
    this.getUnspecifiedType() instanceof IntegralOrEnumType
  }
}

/**
 * Internal module, exposed for testing.
 */
module Internal {
  /**
   * Gets the parent scope of this `Element`, if any.
   * A scope is a `Type` (`Class` / `Enum`), a `Namespace`, a `Block`, a `Function`,
   * or certain kinds of `Statement`.
   * Differs from `Element::getParentScope` when `e` is a `LoopControlVariable`
   */
  Element getParentScope(Element e) {
    /*
     * A `Block` cannot have a `ForStmt` as its parent scope so we have to special case
     * for loop bodies to ensure that identifiers inside the loop bodies have the for stmt as a parent scope.
     * If this is not the case then `i2` in the following example cannot be in `i1`'s potential scope, because
     * the parent scope of `i1` is the `ForStmt` while the transitive closure of the parent scope for `i2` doesn't include
     * outer scope. Blocks can only have blocks as parent scopes.
     * void f() {
     *  for( int i1; ... ) {
     *    for (int i2; ...) {
     *    }
     *  }
     * }
     */

    exists(Loop loop | loop.getAChild() = e and result = loop)
    or
    exists(IfStmt ifStmt |
      (ifStmt.getThen() = e or ifStmt.getElse() = e) and
      result = ifStmt
    )
    or
    exists(SwitchStmt switchStmt | switchStmt.getStmt() = e and result = switchStmt)
    or
    // A catch-block parameter, whose parent is the `Handler`
    exists(CatchBlock c | c.getParameter() = e and result = c.getParent())
    or
    // A catch-block `Handler`, whose parent is the `TryStmt`
    e.(Handler).getParent() = result
    or
    // The parent scope of a lambda is the scope in which the lambda expression is defined.
    //
    // Lambda functions are defined in a generated `Closure` class, as the `operator()` function. We choose the
    // enclosing statement of the lambda expression as the parent scope of the lambda function. This is so we can
    // determine the order of definition if a variable is defined in the same scope as the lambda expression.
    exists(Closure lambdaClosure |
      lambdaClosure.getLambdaFunction() = e and
      lambdaClosure.getLambdaExpression().getEnclosingStmt() = result
    )
    or
    not exists(Loop loop | loop.getAChild() = e) and
    not exists(IfStmt ifStmt | ifStmt.getThen() = e or ifStmt.getElse() = e) and
    not exists(SwitchStmt switchStmt | switchStmt.getStmt() = e) and
    not exists(CatchBlock c | c.getParameter() = e) and
    not e instanceof Handler and
    not exists(Closure lambdaClosure | lambdaClosure.getLambdaFunction() = e) and
    if exists(e.getParentScope())
    then result = e.getParentScope()
    else (
      // Statements do not have a parent scope, so return the enclosing block.
      result = e.(Stmt).getEnclosingBlock()
      or
      // Expressions do not have a parent scope, so return the enclosing block.
      result = e.(Expr).getEnclosingBlock()
    )
  }
}

/** A variable which is defined by the user, rather than being from a third party or compiler generated. */
class UserVariable extends Variable {
  UserVariable() {
    exists(getFile().getRelativePath()) and
    not isCompilerGenerated() and
    not this.(Parameter).getFunction().isCompilerGenerated() and
    // compiler inferred parameters have name of p#0
    not this.(Parameter).getName() = "p#0"
  }
}

/** An element which is the parent scope of at least one other element in the program. */
class Scope extends Element {
  Scope() { this = Internal::getParentScope(_) }

  UserVariable getAVariable() { Internal::getParentScope(result) = this }

  /**
   * Gets the `Variable` with the given `name` that is declared in this scope.
   */
  UserVariable getVariable(string name) {
    result = getAVariable() and
    result.getName() = name
  }

  int getNumberOfVariables() { result = count(getAVariable()) }

  Scope getAnAncestor() { result = this.getStrictParent+() }

  Scope getAChildScope() { result.getStrictParent() = this }

  Scope getStrictParent() { result = Internal::getParentScope(this) }

  Declaration getADeclaration() { Internal::getParentScope(result) = this }

  Expr getAnExpr() { this = Internal::getParentScope(result) }

  private predicate getLocationInfo(
    PreprocessorBranchDirective pbd, string file1, string file2, int startline1, int startline2
  ) {
    pbd.getFile().getAbsolutePath() = file1 and
    this.getFile().getAbsolutePath() = file2 and
    pbd.getLocation().getStartLine() = startline1 and
    this.getLocation().getStartLine() = startline2
  }

  private predicate isStrictlyAfterPbd(PreprocessorBranchDirective pbd) {
    exists(string path, int startLine1, int startLine2 |
      getLocationInfo(pbd, path, path, startLine1, startLine2) and
      startLine1 < startLine2
    )
  }

  private predicate isStrictlyBeforePbd(PreprocessorBranchDirective pbd) {
    exists(string path, int startLine1, int startLine2 |
      getLocationInfo(pbd, path, path, startLine1, startLine2) and
      startLine1 > startLine2
    )
  }

  PreprocessorBranchDirective getAnEnclosingPreprocessorBranchDirective() {
    isStrictlyAfterPbd(result) and isStrictlyBeforePbd(result.getNext())
  }

  predicate isGenerated() { this instanceof GeneratedBlockStmt }

  int getDepth() {
    exists(Scope parent |
      parent = Internal::getParentScope(this) and result = 1 + parent.getDepth()
    )
    or
    not exists(Internal::getParentScope(this)) and result = 0
  }

  /**
   * Holds if `name` is declared in this scope, or in a nested scope.
   */
  private predicate isNameDeclaredInThisOrNestedScope(string name) {
    name = getAVariable().getName()
    or
    isNameDeclaredInNestedScope(name)
  }

  /**
   * Holds if `name` is declared in a nested scope.
   */
  private predicate isNameDeclaredInNestedScope(string name) {
    this.getAChildScope().isNameDeclaredInThisOrNestedScope(name)
  }

  /**
   * Holds if `name` is declared in this scope and is hidden in a child scope.
   */
  private predicate isDeclaredNameHiddenByChild(string name) {
    isNameDeclaredInNestedScope(name) and
    name = getAVariable().getName()
  }

  /**
   * Gets a variable with `name` which is potentially hidden in at least one nested scope.
   */
  private UserVariable getAPotentiallyHiddenVariable(string name) {
    result = getAVariable() and
    result.getName() = name and
    isDeclaredNameHiddenByChild(name)
  }

  /**
   * Holds if `name` is declared above this scope and hidden by this or a nested scope.
   */
  UserVariable getAVariableHiddenByThisOrNestedScope(string name) {
    exists(Scope parent | parent = this.getStrictParent() |
      result = parent.getAPotentiallyHiddenVariable(name) or
      result = parent.getAVariableHiddenByThisOrNestedScope(name)
    ) and
    isNameDeclaredInThisOrNestedScope(name)
  }

  /**
   * Holds if `hiddenVariable` and `hidingVariable` are a candidate hiding pair at this scope.
   */
  private predicate hidesCandidate(
    UserVariable hiddenVariable, UserVariable hidingVariable, string name
  ) {
    (
      // Declared in this scope
      hidingVariable = getVariable(name) and
      hiddenVariable = getAVariableHiddenByThisOrNestedScope(name)
      or
      // Declared in a child scope
      exists(Scope child |
        getAChildScope() = child and
        child.hidesCandidate(hiddenVariable, hidingVariable, name)
      )
    )
  }

  /**
   * Holds if `hiddenVariable` is declared in this scope and hidden by `hidingVariable`.
   */
  predicate hides(UserVariable hiddenVariable, UserVariable hidingVariable, Scope childScope) {
    exists(string name |
      hiddenVariable = getAPotentiallyHiddenVariable(name) and
      childScope = getAChildScope() and
      childScope.hidesCandidate(hiddenVariable, hidingVariable, name)
    )
  }
}

/**
 * A scope representing the generated `operator()` of a lambda function.
 */
class LambdaScope extends Scope {
  Closure closure;

  LambdaScope() { this = closure.getLambdaFunction() }

  override UserVariable getAVariableHiddenByThisOrNestedScope(string name) {
    // Handle special cases for lambdas
    exists(UserVariable hiddenVariable, LambdaExpression lambdaExpr |
      // Find the variable that is potentially hidden inside the lambda
      hiddenVariable = super.getAVariableHiddenByThisOrNestedScope(name) and
      result = hiddenVariable and
      lambdaExpr = closure.getLambdaExpression()
    |
      // A definition can be hidden if it is in scope and it is captured by the lambda,
      exists(LambdaCapture cap |
        lambdaExpr.getACapture() = cap and
        // The outer declaration is captured by the lambda
        hiddenVariable.getAnAccess() = cap.getInitializer()
      )
      or
      // it is is non-local,
      hiddenVariable instanceof GlobalVariable
      or
      // it has static or thread local storage duration,
      (hiddenVariable.isThreadLocal() or hiddenVariable.isStatic())
      or
      //it is a reference that has been initialized with a constant expression.
      hiddenVariable.getType().stripTopLevelSpecifiers() instanceof ReferenceType and
      hiddenVariable.getInitializer().getExpr() instanceof Literal
      or
      // //it const non-volatile integral or enumeration type and has been initialized with a constant expression
      hiddenVariable instanceof NonVolatileConstIntegralOrEnumVariable and
      hiddenVariable.getInitializer().getExpr() instanceof Literal
      or
      //it is constexpr and has no mutable members
      hiddenVariable.isConstexpr() and
      not exists(Class c |
        c = hiddenVariable.getType() and not c.getAMember() instanceof MutableVariable
      )
    )
  }
}

class GeneratedBlockStmt extends BlockStmt {
  GeneratedBlockStmt() { this.getLocation() instanceof UnknownLocation }
}

/** Holds if there exists a translation unit that includes both `f1` and `f2`. */
pragma[noinline]
predicate inSameTranslationUnit(File f1, File f2) {
  exists(TranslationUnit c |
    c.getAUserFile() = f1 and
    c.getAUserFile() = f2
  )
}

/**
 * Holds if there exists a translation unit that includes both `f1` and `f2`.
 *
 * This version is late bound.
 */
bindingset[f1, f2]
pragma[inline_late]
predicate inSameTranslationUnitLate(File f1, File f2) {
  exists(TranslationUnit c |
    c.getAUserFile() = f1 and
    c.getAUserFile() = f2
  )
}

/** A file that is a C/C++ source file */
class SourceFile extends File {
  SourceFile() {
    this instanceof CFile
    or
    this instanceof CppFile
  }
}

/**
 * A source file together with all the headers (N3797 17.6.1.2) and source files included (N3797 16.2)
 * via the preprocessing directive #include, less any source lines skipped by any of the
 * conditional inclusion (N3797 16.1) preprocessing directives, is called a translation unit.
 */
class TranslationUnit extends SourceFile {
  /** Gets a transitively included file. */
  File getATransitivelyIncludedFile() { result = getAnIncludedFile*() }

  /** Gets a file which is within the users source directory. */
  File getAUserFile() {
    result = getATransitivelyIncludedFile() and
    exists(result.getRelativePath())
  }
}

/** Holds if `v2` strictly (`v2` is in an inner scope compared to `v1`) hides `v1`. */
predicate hides_candidateStrict(UserVariable v1, UserVariable v2) {
  exists(Scope parentScope, Scope childScope | parentScope.hides(v1, v2, childScope) |
    // If v1 is a local variable defined in a `DeclStmt` ensure that it is declared before `v2`,
    // otherwise it would not be hidden
    (
      parentScope instanceof BlockStmt and
      exists(DeclStmt ds | ds.getADeclaration() = v1) and
      exists(parentScope.(BlockStmt).getIndexOfStmt(childScope))
    )
    implies
    exists(BlockStmt bs, DeclStmt v1Stmt, Stmt v2Stmt |
      bs = parentScope and
      v2Stmt = childScope and
      v1Stmt.getADeclaration() = v1
    |
      bs.getIndexOfStmt(v1Stmt) <= bs.getIndexOfStmt(v2Stmt)
    )
  ) and
  inSameTranslationUnitLate(v1.getFile(), v2.getFile()) and
  not (v1.isMember() or v2.isMember())
}

/** Holds if `v2` strictly (`v2` is in an inner scope compared to `v1`) hides `v1`. */
predicate hidesStrict(UserVariable v1, UserVariable v2) {
  hides_candidateStrict(v1, v2) and
  // Confirm that there's no closer candidate variable which `v2` hides
  not exists(UserVariable mid |
    hides_candidateStrict(v1, mid) and
    hides_candidateStrict(mid, v2)
  )
}

/** Holds if `decl` has namespace scope. */
predicate hasNamespaceScope(Declaration decl) {
  // getNamespace always returns a namespace (e.g. the global namespace).
  exists(Namespace n | namespacembrs(unresolveElement(n), underlyingElement(decl)))
}

/** Holds if `decl` has class scope. */
predicate hasClassScope(Declaration decl) { exists(decl.getDeclaringType()) }

/** Holds if `decl` has block scope. */
predicate hasBlockScope(Declaration decl) { exists(BlockStmt b | b.getADeclaration() = decl) }

/**
 * identifiers in nested (named/nonglobal) namespaces are exceptions to hiding due to being able access via fully qualified ids
 */
bindingset[outerDecl, innerDecl]
pragma[inline_late]
predicate excludedViaNestedNamespaces(UserVariable outerDecl, UserVariable innerDecl) {
  exists(Namespace inner, Namespace outer |
    outer.getAChildNamespace+() = inner and
    //outer is not global
    not outer instanceof GlobalNamespace and
    not outer.isAnonymous() and
    not inner.isAnonymous() and
    innerDecl.getNamespace() = inner and
    outerDecl.getNamespace() = outer
  )
}
