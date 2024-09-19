/**
 * Provides a library which includes a `problems` predicate for reporting unnecessarily exposed identifiers due to too broad of a scope.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Scope
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.Customizations

class ExternalCall extends Call {
  ExternalCall() {
    exists(Function f | this.getTarget() = f |
      not f.hasDefinition() and not f.isCompilerGenerated()
    )
  }
}

class LoopOrSwitchBody extends BlockStmt {
  LoopOrSwitchBody() {
    exists(Loop l | l.getStmt() = this.getParentScope*())
    or
    exists(SwitchStmt ss | ss.getStmt() = this)
  }
}

/* Gets a scope for `b` that is an ancestor of `b`, but is not a loop or switch scope. */
Scope getCandidateScope(Scope b) {
  if b instanceof LoopOrSwitchBody or b instanceof ControlStructure
  then result = getCandidateScope(b.getStrictParent())
  else
    if b.isGenerated()
    then result = b.getStrictParent()
    else result = b
}

private predicate getLocationInfo(
  CandidateDeclaration d, PreprocessorBranchDirective pbd, int startline, int endline, string path1,
  string path2
) {
  d.getLocation().getEndLine() = endline and
  pbd.getLocation().getStartLine() = startline and
  d.getFile().getAbsolutePath() = path1 and
  pbd.getFile().getAbsolutePath() = path2
}

predicate isStrictlyBefore(CandidateDeclaration d, PreprocessorBranchDirective branch) {
  exists(string path, int startLine, int endLine |
    getLocationInfo(d, branch, startLine, endLine, path, path) and
    endLine < startLine
  )
}

Variable getADependentVariable(Variable v) {
  exists(VariableAccess va |
    va.getTarget() = result and v.getInitializer().getExpr().getAChild*() = va
  )
}

/**
 * Holds if it is assigned a value that is modified in between the declaration of `v` and a use of `v`.
 */
predicate isTempVariable(LocalVariable v) {
  exists(
    DeclStmt ds, VariableDeclarationEntry vde, Variable dependentVariable, Expr sideEffect,
    VariableAccess va
  |
    v.getAnAccess() = va and
    dependentVariable = getADependentVariable(v) and
    exists(
      BasicBlock declarationStmtBb, BasicBlock sideEffectBb, BasicBlock variableAccessBb,
      int declarationStmtPos, int sideEffectPos, int variableAccessPos
    |
      declarationStmtBb.getNode(declarationStmtPos) = ds and
      variableAccessBb.getNode(variableAccessPos) = va
    |
      (
        (
          sideEffect.(VariableEffect).getTarget() = dependentVariable and
          if not sideEffect.getEnclosingFunction() = va.getEnclosingFunction()
          then
            exists(FunctionCall call |
              call.getEnclosingFunction() = va.getEnclosingFunction() and
              call.getTarget().calls(sideEffect.getEnclosingFunction()) and
              sideEffectBb.getNode(sideEffectPos) = call
            )
          else sideEffectBb.getNode(sideEffectPos) = sideEffect
        )
        or
        dependentVariable instanceof GlobalVariable and
        sideEffect instanceof ExternalCall and
        ds.getEnclosingFunction() = sideEffect.getEnclosingFunction() and
        sideEffectBb.getNode(sideEffectPos) = sideEffect
      ) and
      (
        declarationStmtBb.getASuccessor+() = sideEffectBb
        or
        declarationStmtBb = sideEffectBb and declarationStmtPos < sideEffectPos
      ) and
      (
        sideEffectBb.getASuccessor+() = variableAccessBb
        or
        sideEffectBb = variableAccessBb and sideEffectPos < variableAccessPos
      )
    ) and
    vde.getDeclaration() = v and
    ds.getDeclarationEntry(_) = vde
  )
}

private predicate isTypeUse(Type t1, Type t2) {
  t1.getUnspecifiedType() = t2
  or
  t1.(PointerType).getBaseType().getUnspecifiedType() = t2
  or
  t1.(ReferenceType).getBaseType().getUnspecifiedType() = t2
  or
  t1.(ArrayType).getBaseType().getUnspecifiedType() = t2
}

newtype TDeclarationAccess =
  ObjectAccess(Variable v, VariableAccess va) {
    va = v.getAnAccess() or
    v.(TemplateVariable).getAnInstantiation().getAnAccess() = va
  } or
  /* Type access can be done in a declaration or an expression (e.g., static member function call) */
  TypeAccess(Type t, Element access) {
    isTypeUse(access.(Variable).getUnspecifiedType(), t)
    or
    exists(ClassTemplateInstantiation cti |
      isTypeUse(cti.getATemplateArgument(), t) and
      access.(Variable).getUnspecifiedType() = cti
    )
    or
    exists(FunctionTemplateInstantiation fti |
      isTypeUse(fti.getATemplateArgument(), t) and
      fti = access
    )
    or
    exists(FunctionCall call, MemberFunction mf |
      call = access and call.getTarget() = mf and mf.isStatic() and mf.getDeclaringType() = t
    )
    or
    exists(Function f |
      isTypeUse(f.getType(), t) and
      f = access
    )
  }

class DeclarationAccess extends TDeclarationAccess {
  Location getLocation() {
    exists(VariableAccess va, Variable v | this = ObjectAccess(v, va) and result = va.getLocation())
    or
    exists(Element access |
      this = TypeAccess(_, access) and
      result = access.getLocation()
    )
  }

  string toString() {
    exists(Variable v | this = ObjectAccess(v, _) and result = "Object access for " + v.getName())
    or
    exists(Type t |
      this = TypeAccess(t, _) and
      result = "Type access for " + t.getName()
    )
  }

  /* Gets the declaration that is being accessed. */
  Declaration getDeclaration() {
    this = ObjectAccess(result, _)
    or
    this = TypeAccess(result, _)
  }

  /* Gets the declaration or expression that uses the type being accessed. */
  Element getUnderlyingTypeAccess() { this = TypeAccess(_, result) }

  VariableAccess getUnderlyingObjectAccess() { this = ObjectAccess(_, result) }

  /* Gets the scope of the access. */
  Scope getScope() {
    exists(VariableAccess va |
      va = getUnderlyingObjectAccess() and
      result.getAnExpr() = va
    )
    or
    exists(Element e | e = getUnderlyingTypeAccess() and result = e.getParentScope())
  }

  /* Holds if a type access is generated from the template instantiation `instantionion` */
  predicate isFromTemplateInstantiation(Element instantiation) {
    exists(Element access |
      this = TypeAccess(_, access) and access.isFromTemplateInstantiation(instantiation)
    )
  }

  predicate isCompilerGenerated() {
    exists(VariableAccess va | va = getUnderlyingObjectAccess() and va.isCompilerGenerated())
    or
    exists(Element e |
      e = getUnderlyingTypeAccess() and
      (compgenerated(underlyingElement(e)) or compgenerated(underlyingElement(e.getParentScope())))
    )
  }
}

class CandidateDeclaration extends Declaration {
  CandidateDeclaration() {
    this instanceof LocalVariable and
    not this.(LocalVariable).isConstexpr() and
    not this.isFromTemplateInstantiation(_)
    or
    this instanceof GlobalOrNamespaceVariable and
    not this.isFromTemplateInstantiation(_) and
    not this.(GlobalOrNamespaceVariable).isConstexpr()
    or
    this instanceof Type and
    not this instanceof ClassTemplateInstantiation and
    not this instanceof TemplateParameter
  }
}

/* Gets the scopes that include all the declaration accesses for declaration `d`. */
Scope possibleScopesForDeclaration(CandidateDeclaration d) {
  forex(Scope scope, DeclarationAccess da |
    da.getDeclaration() = d and
    // Exclude declaration accesses that are compiler generated so we can minimize the visibility of types.
    // Otherwise, for example, we cannot reduce the scope of classes with compiler generated member functions based on
    // declaration accesses.
    not da.isCompilerGenerated() and
    not da.isFromTemplateInstantiation(_) and
    scope = da.getScope()
  |
    result = scope.getStrictParent*()
  ) and
  // Limit the best scope to block statements and namespaces or control structures
  (
    result instanceof BlockStmt and
    // Template variables cannot be in block scope
    not d instanceof TemplateVariable
    or
    result instanceof Namespace
  )
}

/* Gets the smallest scope that includes all the declaration accesses of declaration `d`. */
Scope bestScopeForDeclarationEntry(CandidateDeclaration d, Scope currentScope) {
  result = possibleScopesForDeclaration(d) and
  not exists(Scope other | other = possibleScopesForDeclaration(d) | result = other.getAnAncestor()) and
  currentScope.getADeclaration() = d and
  result.getAnAncestor() = currentScope and
  not result instanceof LoopOrSwitchBody and
  not result.isGenerated()
}

/**
 * Gets a string suitable for printing a scope in an alert message, that includes an `$@`
 * formatting string.
 *
 * This is necessary because some scopes (e.g. `Namespace`) do not have meaningful
 * locations in the database and the alert message will not render the name if that is the case.
 */
string getScopeDescription(Scope s) {
  if s instanceof GlobalNamespace then result = "the global namespace scope$@" else result = "$@"
}

abstract class UnnecessaryExposedIdentifierDeclarationSharedSharedQuery extends Query { }

Query getQuery() { result instanceof UnnecessaryExposedIdentifierDeclarationSharedSharedQuery }

query predicate problems(
  CandidateDeclaration d, string message, Scope currentScope, string msgP1, Scope candidateScope,
  string msgP2
) {
  not isExcluded(d, getQuery()) and
  candidateScope = bestScopeForDeclarationEntry(d, currentScope) and
  // We can't reduce the scope if the value stored in the declaration is changed before the declared
  // variable is used, because this would change the semantics of the use.
  (d instanceof Variable implies not isTempVariable(d)) and
  not exists(AddressOfExpr e | e.getAddressable() = d) and
  // We can't reduce the scope of the declaration if its minimal scope resides inside a preprocessor
  // branch directive while the current scope isn't. This can result in an incorrect program
  // where a variable is used but not declared.
  not exists(PreprocessorBranchDirective branch |
    isStrictlyBefore(d, branch) and
    branch = candidateScope.getAnEnclosingPreprocessorBranchDirective()
  ) and
  // We can't promote a class to a local class if it has static data members (See [class.local] paragraph 4 N3797.)
  (
    (d instanceof Class and candidateScope.getStrictParent() instanceof Function)
    implies
    not exists(Variable member | d.(Class).getAMember() = member and member.isStatic())
  ) and
  not candidateScope.isAffectedByMacro() and
  msgP1 = "scope" and
  msgP2 = "scope" and
  message =
    "The declaration " + d.getName() + " should be moved from " + getScopeDescription(currentScope) +
      " into the " + getScopeDescription(candidateScope) + " too minimize its visibility."
}
