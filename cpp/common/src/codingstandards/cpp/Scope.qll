/**
 * A module to reason about the scope of elements.
 */

import cpp

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
    not exists(Loop loop | loop.getAChild() = e) and
    not exists(IfStmt ifStmt | ifStmt.getThen() = e or ifStmt.getElse() = e) and
    not exists(SwitchStmt switchStmt | switchStmt.getStmt() = e) and
    if exists(e.getParentScope())
    then result = e.getParentScope()
    else (
      // Statements do no have a parent scope, so return the enclosing block.
      result = e.(Stmt).getEnclosingBlock()
      or
      result = e.(Expr).getEnclosingBlock()
      or
      // Catch block parameters don't have an enclosing scope, so attach them to the
      // the block itself
      exists(CatchBlock cb |
        e = cb.getParameter() and
        result = cb
      )
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
    exists(Scope child |
      child.getStrictParent() = this and
      child.isNameDeclaredInThisOrNestedScope(name)
    )
  }

  /**
   * Holds if `name` is declared in this scope and is hidden in a child scope.
   */
  private predicate isDeclaredNameHiddenByChild(string name) {
    isNameDeclaredInNestedScope(name) and
    name = getAVariable().getName()
  }

  /**
   * Gets a variable with `name` which is hidden in at least one nested scope.
   */
  UserVariable getAHiddenVariable(string name) {
    result = getAVariable() and
    result.getName() = name and
    isDeclaredNameHiddenByChild(name)
  }

  /**
   * Holds if `name` is declared above this scope and hidden by this or a nested scope.
   */
  private predicate isNameDeclaredAboveHiddenByThisOrNested(string name) {
    (
      this.getStrictParent().isDeclaredNameHiddenByChild(name) or
      this.getStrictParent().isNameDeclaredAboveHiddenByThisOrNested(name)
    ) and
    isNameDeclaredInThisOrNestedScope(name)
  }

  /**
   * Gets a variable with `name` which is declared above and hidden by a variable in this or a nested scope.
   */
  UserVariable getAHidingVariable(string name) {
    isNameDeclaredAboveHiddenByThisOrNested(name) and
    (
      // Declared in this scope
      getAVariable().getName() = name and
      result = getAVariable() and
      result.getName() = name
      or
      // Declared in a child scope
      exists(Scope child |
        child.getStrictParent() = this and
        child.isNameDeclaredInThisOrNestedScope(name) and
        result = child.getAHidingVariable(name)
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
  exists(Scope s, string name |
    v1 = s.getStrictParent().getAHiddenVariable(name) and
    v2 = s.getAHidingVariable(name) and
    not v1 = v2
  ) and
  inSameTranslationUnitLate(v1.getFile(), v2.getFile()) and
  not (v1.isMember() or v2.isMember()) and
  (
    // If v1 is a local variable, ensure that v1 is declared before v2
    (
      v1 instanceof LocalVariable and
      // Ignore variables declared in conditional expressions, as they apply to
      // the nested scope
      not v1 = any(ConditionDeclExpr cde).getVariable() and
      // Ignore variables declared in loops
      not exists(Loop l | l.getADeclaration() = v1)
    )
    implies
    exists(BlockStmt bs, DeclStmt v1Stmt, Stmt v2Stmt |
      v1 = v1Stmt.getADeclaration() and
      getEnclosingStmt(v2).getParentStmt*() = v2Stmt
    |
      bs.getIndexOfStmt(v1Stmt) <= bs.getIndexOfStmt(v2Stmt)
    )
  )
}

/**
 * Gets the enclosing statement of the given variable, if any.
 */
private Stmt getEnclosingStmt(LocalScopeVariable v) {
  result.(DeclStmt).getADeclaration() = v
  or
  exists(ConditionDeclExpr cde |
    cde.getVariable() = v and
    result = cde.getEnclosingStmt()
  )
  or
  exists(CatchBlock cb |
    cb.getParameter() = v and
    result = cb.getEnclosingStmt()
  )
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
