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
 * Holds if declaration `innerDecl`, declared in a lambda, hides a declaration `outerDecl` captured by the lambda.
 */
predicate hiddenInLambda(UserVariable outerDecl, UserVariable innerDecl) {
  exists(Scope s, Closure le |
    //innerDecl declared inside of the lambda
    s.getADeclaration() = innerDecl and
    s.getAnAncestor() = le and
    le.getEnclosingFunction().getBasicBlock().(Scope) = outerDecl.getParentScope() and
    exists(LambdaCapture cap |
      outerDecl.getAnAccess() = cap.getInitializer().(VariableAccess) and
      le.getLambdaExpression().getACapture() = cap
    ) and
    innerDecl.getName() = outerDecl.getName()
  )
}

query predicate problems(
  UserDeclaration innerDecl, string message, UserDeclaration outerDecl, string varName
) {
  not isExcluded(outerDecl, getQuery()) and
  not isExcluded(innerDecl, getQuery()) and
  //ignore template variables for this rule
  not outerDecl instanceof TemplateVariable and
  not innerDecl instanceof TemplateVariable and
  //ignore types for this rule as the Misra C/C++ 23 version of this rule (rule 6.4.1 and 6.4.2) focuses solely on variables and functions
  not innerDecl instanceof Type and
  not outerDecl instanceof Type and
  (hidesStrict(outerDecl, innerDecl) or hiddenInLambda(outerDecl, innerDecl)) and
  not excludedViaNestedNamespaces(outerDecl, innerDecl) and
  varName = outerDecl.getName() and
  message = "Declaration is hiding declaration $@."
}
