/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Scope
import codingstandards.cpp.ConstHelpers

abstract class IdentifierHiddenSharedQuery extends Query { }

Query getQuery() { result instanceof IdentifierHiddenSharedQuery }

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
 * Holds if declaration `innerDecl`, declared in a lambda, hides a declaration `outerDecl` by the lambda.
 */
predicate hiddenInLambda(UserVariable outerDecl, UserVariable innerDecl) {
  exists(
    Scope innerScope, LambdaExpression lambdaExpr, Scope lambdaExprScope, Scope outerScope,
    Closure lambdaClosure
  |
    // The variable `innerDecl` is declared inside of the lambda.
    innerScope.getADeclaration() = innerDecl and
    // Because a lambda is compiled down to a closure, we need to use the closure to determine if the declaration
    // is part of the lambda.
    innerScope.getAnAncestor() = lambdaClosure and
    // Next we determine the scope of the lambda expression to determine if `outerDecl` is visible in the scope of the lambda.
    lambdaClosure.getLambdaExpression() = lambdaExpr and
    lambdaExprScope.getAnExpr() = lambdaExpr and
    outerScope.getADeclaration() = outerDecl and
    lambdaExprScope.getStrictParent*() = outerScope and
    (
      // A definition can be hidden if it is in scope and it is captured by the lambda,
      exists(LambdaCapture cap |
        lambdaExpr.getACapture() = cap and
        // The outer declaration is captured by the lambda
        outerDecl.getAnAccess() = cap.getInitializer()
      )
      or
      // it is is non-local,
      outerDecl instanceof GlobalVariable
      or
      // it has static or thread local storage duration,
      (outerDecl.isThreadLocal() or outerDecl.isStatic())
      or
      //it is a reference that has been initialized with a constant expression.
      outerDecl.getType().stripTopLevelSpecifiers() instanceof ReferenceType and
      outerDecl.getInitializer().getExpr() instanceof Literal
      or
      // //it const non-volatile integral or enumeration type and has been initialized with a constant expression
      outerDecl instanceof NonVolatileConstIntegralOrEnumVariable and
      outerDecl.getInitializer().getExpr() instanceof Literal
      or
      //it is constexpr and has no mutable members
      outerDecl.isConstexpr() and
      not exists(Class c |
        c = outerDecl.getType() and not c.getAMember() instanceof MutableVariable
      )
    ) and
    // Finally, the variables must have the same names.
    innerDecl.getName() = outerDecl.getName()
  )
}

query predicate problems(
  UserVariable innerDecl, string message, UserVariable outerDecl, string varName
) {
  not isExcluded(outerDecl, getQuery()) and
  not isExcluded(innerDecl, getQuery()) and
  //ignore template variables for this rule
  not outerDecl instanceof TemplateVariable and
  not innerDecl instanceof TemplateVariable and
  (hidesStrict(outerDecl, innerDecl) or hiddenInLambda(outerDecl, innerDecl)) and
  not excludedViaNestedNamespaces(outerDecl, innerDecl) and
  varName = outerDecl.getName() and
  message = "Variable is hiding variable $@."
}
