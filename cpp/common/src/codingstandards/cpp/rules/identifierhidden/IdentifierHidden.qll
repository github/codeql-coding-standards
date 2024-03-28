/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Scope

abstract class IdentifierHiddenSharedQuery extends Query { }

Query getQuery() { result instanceof IdentifierHiddenSharedQuery }

/**
 * There is a lambda that contains a declaration
 * that hides something that is captured
 * and the lambda exists in the function where this lamda is enclosed
 */
predicate hiddenInLambda(UserDeclaration v2, UserDeclaration v1) {
  exists(Scope s, Closure le |
    s.getADeclaration() = v2 and
    s.getAnAncestor() = le and
    le.getEnclosingFunction().getBasicBlock().(Scope) = v1.getParentScope() and
    exists(LambdaCapture cap, Variable v |
      v.getAnAccess() = cap.getInitializer().(VariableAccess) and
      v = v1 and
      le.getLambdaExpression().getACapture() = cap
    ) and
    v2.getName() = v1.getName()
  )
}

query predicate problems(UserDeclaration v2, string message, UserDeclaration v1, string varName) {
  not isExcluded(v1, getQuery()) and
  not isExcluded(v2, getQuery()) and
  //ignore template variables for this rule
  not v1 instanceof TemplateVariable and
  not v2 instanceof TemplateVariable and
  //ignore types for this rule
  not v2 instanceof Type and
  not v1 instanceof Type and
  (hidesStrict(v1, v2) or hiddenInLambda(v2, v1)) and
  not excludedViaNestedNamespaces(v2, v1) and
  varName = v1.getName() and
  message = "Declaration is hiding declaration $@."
}
