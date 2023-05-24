/**
 * A module to reason about the scope of elements.
 */

import cpp

/**
 * Gets the parent scope of this `Element`, if any.
 * A scope is a `Type` (`Class` / `Enum`), a `Namespace`, a `Block`, a `Function`,
 * or certain kinds of `Statement`.
 * Differs from `Element::getParentScope` when `e` is a `LoopControlVariable`
 */
private Element getParentScope(Element e) {
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

  exists(Loop loop | loop.getStmt() = e and result = loop)
  or
  exists(IfStmt ifStmt |
    (ifStmt.getThen() = e or ifStmt.getElse() = e) and
    result = ifStmt
  )
  or
  exists(SwitchStmt switchStmt | switchStmt.getStmt() = e and result = switchStmt)
  or
  not result.(Loop).getStmt() = e and
  not result.(IfStmt).getThen() = e and
  not result.(IfStmt).getElse() = e and
  not result.(SwitchStmt).getStmt() = e and
  if exists(e.getParentScope())
  then result = e.getParentScope()
  else (
    // Statements do no have a parent scope, so return the enclosing block.
    result = e.(Stmt).getEnclosingBlock() or result = e.(Expr).getEnclosingBlock()
  )
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
  Scope() { this = getParentScope(_) }

  UserVariable getAVariable() { getParentScope(result) = this }

  int getNumberOfVariables() { result = count(getAVariable()) }

  Scope getAnAncestor() { result = this.getStrictParent+() }

  Scope getStrictParent() { result = getParentScope(this) }

  Declaration getADeclaration() { getParentScope(result) = this }

  Expr getAnExpr() { this = getParentScope(result) }

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
    exists(Scope parent | parent = getParentScope(this) and result = 1 + parent.getDepth())
    or
    not exists(getParentScope(this)) and result = 0
  }
}

class GeneratedBlockStmt extends BlockStmt {
  GeneratedBlockStmt() { this.getLocation() instanceof UnknownLocation }
}

/** Gets a variable that is in the potential scope of variable `v`. */
private UserVariable getPotentialScopeOfVariable_candidate(UserVariable v) {
  exists(Scope s |
    result = s.getAVariable() and
    (
      // Variable in an ancestor scope, but only if there are less than 100 variables in this scope
      v = s.getAnAncestor().getAVariable() and
      s.getNumberOfVariables() < 100
      or
      // In the same scope, but not the same variable, and choose just one to report
      v = s.getAVariable() and
      not result = v and
      v.getName() <= result.getName()
    )
  )
}

/** Gets a variable that is in the potential scope of variable `v`. */
private UserVariable getOuterScopesOfVariable_candidate(UserVariable v) {
  exists(Scope s |
    result = s.getAVariable() and
    (
      // Variable in an ancestor scope, but only if there are less than 100 variables in this scope
      v = s.getAnAncestor().getAVariable() and
      s.getNumberOfVariables() < 100
    )
  )
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
 * Gets a user variable which occurs in the "potential scope" of variable `v`.
 */
cached
UserVariable getPotentialScopeOfVariable(UserVariable v) {
  result = getPotentialScopeOfVariable_candidate(v) and
  inSameTranslationUnit(v.getFile(), result.getFile())
}

/**
 * Gets a user variable which occurs in the "outer scope" of variable `v`.
 */
cached
UserVariable getPotentialScopeOfVariableStrict(UserVariable v) {
  result = getOuterScopesOfVariable_candidate(v) and
  inSameTranslationUnit(v.getFile(), result.getFile())
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

/** Holds if `v2` may hide `v1`. */
private predicate hides_candidate(UserVariable v1, UserVariable v2) {
  not v1 = v2 and
  v2 = getPotentialScopeOfVariable(v1) and
  v1.getName() = v2.getName() and
  // Member variables cannot hide other variables nor be hidden because the can be referenced through their qualified name.
  not (v1.isMember() or v2.isMember())
}

/** Holds if `v2` may hide `v1`. */
private predicate hides_candidateStrict(UserVariable v1, UserVariable v2) {
  not v1 = v2 and
  v2 = getPotentialScopeOfVariableStrict(v1) and
  v1.getName() = v2.getName() and
  // Member variables cannot hide other variables nor be hidden because the can be referenced through their qualified name.
  not (v1.isMember() or v2.isMember())
}

/** Holds if `v2` hides `v1`. */
predicate hides(UserVariable v1, UserVariable v2) {
  hides_candidate(v1, v2) and
  // Confirm that there's no closer candidate variable which `v2` hides
  not exists(UserVariable mid |
    hides_candidate(v1, mid) and
    hides_candidate(mid, v2)
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
