/**
 * Provides a library which includes a `problems` predicate for reporting attempts of accessing
 * non-existing members through a pointer-to-member pointer.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Expr
import semmle.code.cpp.dataflow.DataFlow

abstract class AccessOfNonExistingMemberThroughPointerToMemberSharedQuery extends Query { }

Query getQuery() { result instanceof AccessOfNonExistingMemberThroughPointerToMemberSharedQuery }

/**
 * Gets the dynamic type of expression `e`, if any.
 *
 * For expression refering to polymorphic types the static type can differ from the dynamic type that is computed
 * during run-time. The dynamic type is determined by the type of the object at creation and not how it is used in an expression.
 *
 * To determine the dynamic type we track objects to their creation and exclude tracking through arrays and fields.
 */
private Type getDynamicType(Expr e) {
  e.getUnderlyingType() instanceof PolymorphicClass and result = e.getUnderlyingType()
  or
  e.getUnderlyingType().(DerivedType).getBaseType().getUnderlyingType() instanceof PolymorphicClass and
  (
    exists(Expr source |
      DataFlow::localExprFlow(source, e) and
      (
        // The source is a object creation through a new expression.
        result = source.(NewExpr).getAllocatedType()
        or
        // The source is result of a function call, so determine possible dynamic types
        // by looking at the returned types.
        result =
          getDynamicType(source
                .(FunctionCall)
                .getTarget()
                .getBlock()
                .getAStmt()
                .(ReturnStmt)
                .getExpr())
        or
        // The source is a parameter access, so determine the possible dynamic type through
        // caller arguments.
        exists(Parameter p, FunctionCall caller |
          source.(VariableAccess).getTarget() = p and
          p.getFunction().getACallToThisFunction() = caller and
          result = getDynamicType(caller.getArgument(p.getIndex()))
        )
      )
    )
    or
    // Determine the dynamic type for pointers assigned through a function call argument.
    // i.e, T* t; f(...,&t,...) with f(...,T** t, ...) { *t = ... }
    // This currently only supports the above case where the function parameter flows to a
    // dereference expression that is the lvalue of an assignment.
    exists(
      DataFlow::Node postUpdateNode, FunctionCall call, Function callee, int i, Parameter p,
      PointerDereferenceExpr deref, Assignment a
    |
      postUpdateNode.(DataFlow::PostUpdateNode).getPreUpdateNode().asExpr() = call.getArgument(i) and
      DataFlow::localFlow(postUpdateNode, DataFlow::exprNode(e)) and
      call.getTarget() = callee and
      callee.getParameter(i) = p and
      a.getLValue() = deref and
      DataFlow::localExprFlow(p.getAnAccess(), deref.getOperand()) and
      result = getDynamicType(a.getRValue())
    )
  )
}

private predicate cannotAccessMember(
  PointerToMemberExpr pointerToMemberExpr, PolymorphicClass objectExprDynamicType,
  Expr pointedToMember, Class memberDeclaringType
) {
  DataFlow::localExprFlow(pointedToMember, pointerToMemberExpr.getPointerExpr()) and
  (
    memberDeclaringType = pointedToMember.(FunctionAccess).getTarget().getDeclaringType()
    or
    memberDeclaringType = pointedToMember.(PointerToFieldLiteral).getTarget().getDeclaringType()
  ) and
  objectExprDynamicType = getDynamicType(pointerToMemberExpr.getObjectExpr()) and
  not objectExprDynamicType.getABaseClass*() = memberDeclaringType
}

query predicate problems(
  PointerToMemberExpr pointerToMemberExpr, string message, PolymorphicClass objectExprDynamicType,
  string objectExprDynamicTypeName, VariableAccess objectExpr, string objectExprName,
  Declaration memberDecl, string memberDeclName, Class memberDeclType, string memberDeclTypeName,
  VariableAccess pointerExpr, string pointerExprName
) {
  not isExcluded(pointerToMemberExpr, getQuery()) and
  exists(Expr pointedToMember |
    cannotAccessMember(pointerToMemberExpr, objectExprDynamicType, pointedToMember, memberDeclType) and
    objectExprDynamicTypeName = objectExprDynamicType.getName() and
    objectExpr = pointerToMemberExpr.getObjectExpr() and
    objectExprName = objectExpr.getTarget().getName() and
    message =
      "The dynamic type $@ of $@ cannot access non-existing member $@ of $@ pointed to by $@." and
    (
      memberDecl = pointedToMember.(FunctionAccess).getTarget()
      or
      memberDecl = pointedToMember.(PointerToFieldLiteral).getTarget()
    ) and
    memberDeclName = memberDecl.getName() and
    memberDeclTypeName = memberDeclType.getName() and
    pointerExpr = pointerToMemberExpr.getPointerExpr() and
    pointerExprName = pointerExpr.getTarget().getName()
  )
}
