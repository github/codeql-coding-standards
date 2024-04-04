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
 * a `IntegralOrEnumType` that is nonvolatile and const
 */
class NonVolatileConstIntegralOrEnumType extends IntegralOrEnumType {
  NonVolatileConstIntegralOrEnumType() {
    not this.isVolatile() and
    this.isConst()
  }
}

/**
 * Holds if declaration `innerDecl`, declared in a lambda, hides a declaration `outerDecl` captured by the lambda.
 */
predicate hiddenInLambda(UserVariable outerDecl, UserVariable innerDecl) {
  exists(Scope s, Closure le |
    //innerDecl declared inside of the lambda
    s.getADeclaration() = innerDecl and
    s.getAnAncestor() = le and
    //a variable can be accessed (therefore hide) another when:
    //it is explicitly captured
    (
      exists(LambdaCapture cap |
        outerDecl.getAnAccess() = cap.getInitializer().(VariableAccess) and
        le.getLambdaExpression().getACapture() = cap and
        //captured variable (outerDecl) is in the same (function) scope as the lambda itself
        outerDecl.getParentScope() = le.getEnclosingFunction().getBasicBlock().(Scope)
      )
      or
      //is non-local
      outerDecl instanceof GlobalVariable
      or
      //has static or thread local storage duration
      (outerDecl.isThreadLocal() or outerDecl.isStatic())
      or
      //is a reference that has been initialized with a constant expression.
      outerDecl.getType().stripTopLevelSpecifiers() instanceof ReferenceType and
      exists(outerDecl.getInitializer().getExpr().getValue())
      or
      //const non-volatile integral or enumeration type and has been initialized with a constant expression
      outerDecl.getType() instanceof NonVolatileConstIntegralOrEnumType and
      exists(outerDecl.getInitializer().getExpr().getValue())
      or
      //is constexpr and has no mutable members
      outerDecl.isConstexpr() and
      not exists(Class c |
        c = outerDecl.getType() and not c.getAMember() instanceof MutableVariable
      )
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
