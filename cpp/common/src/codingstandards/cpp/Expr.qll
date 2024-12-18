import cpp
private import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import codingstandards.cpp.AccessPath

/**
 * A unary or binary arithmetic operation.
 */
class ArithmeticOperation extends Operation {
  ArithmeticOperation() {
    this instanceof UnaryArithmeticOperation or this instanceof BinaryArithmeticOperation
  }
}

/** A full expression as defined in [intro.execution] of N3797. */
class FullExpr extends Expr {
  FullExpr() {
    // A full-expression is not a subexpression
    not exists(Expr p | this.getParent() = p)
    or
    // A sub-expression that is an unevaluated operand
    this.isUnevaluated()
  }
}

/** A subexpression of another expression. */
class ConstituentExpr extends Expr {
  ConstituentExpr() { exists(FullExpr e | e = this.getParent+()) }

  FullExpr getFullExpr() { result.getAChild+() = this }
}

/** An overloaded assign expression. */
class OverloadedAssignExpr extends FunctionCall {
  OverloadedAssignExpr() { this.getTarget().getName() = "operator=" }

  Expr getRValue() { result = this.getArgument(0) }

  Expr getLValue() { result = this.getQualifier() }
}

/** A non-overloaded or overloaded assign expression */
class AnyAssignExpr extends Expr {
  AnyAssignExpr() {
    this instanceof OverloadedAssignExpr
    or
    this instanceof AssignExpr
  }

  Expr getLValue() {
    result = this.(OverloadedAssignExpr).getLValue()
    or
    result = this.(AssignExpr).getLValue()
  }

  Expr getRValue() {
    result = this.(OverloadedAssignExpr).getRValue()
    or
    result = this.(AssignExpr).getRValue()
  }
}

class MemberAssignExpr extends AnyAssignExpr {
  MemberAssignExpr() {
    this.getLValue().(VariableAccess).getQualifier() instanceof ThisExpr
    or
    this.getLValue().(ArrayExpr).getArrayBase().(VariableAccess).getQualifier() instanceof ThisExpr
  }
}

AnyAssignExpr getAMemberCopyAssignment(MemberFunction f) {
  exists(ImplicitQualifier qa, FieldQualifier lhs, FieldQualifier rhsRoot, FieldQualifier rhs |
    lhs.asExpr() = result.getLValue() and
    rhsRoot.asExpr() = f.getAParameter().getAnAccess() and
    rhs.asExpr() = result.getRValue()
  |
    hasStructuralEquivalentAccessPath(qa, lhs, rhsRoot, rhs)
  )
  or
  exists(
    ImplicitQualifier qa, FieldQualifier lhs, FieldQualifier rhsRoot, FieldQualifier rhs, GVN offset
  |
    lhs.asExpr() = result.getLValue().(ArrayExpr).getArrayBase() and
    rhsRoot.asExpr() = f.getAParameter().getAnAccess() and
    rhs.asExpr() = result.getRValue().(ArrayExpr).getArrayBase() and
    offset.getAnExpr() = result.getLValue().(ArrayExpr).getArrayOffset() and
    offset.getAnExpr() = result.getRValue().(ArrayExpr).getArrayOffset()
  |
    hasStructuralEquivalentAccessPath(qa, lhs, rhsRoot, rhs)
  )
}

AnyAssignExpr getAMemberMoveAssignment(MemberFunction f) {
  result = getAMemberCopyAssignment(f)
  or
  exists(
    ImplicitQualifier qa, FieldQualifier lhs, FieldQualifier rhsRoot, FieldQualifier rhs,
    FunctionCall move
  |
    lhs.asExpr() = result.getLValue() and
    rhsRoot.asExpr() = f.getAParameter().getAnAccess() and
    move = result.getRValue() and
    move.getTarget().hasQualifiedName("std", "move") and
    rhs.asExpr() = move.getArgument(0)
  |
    hasStructuralEquivalentAccessPath(qa, lhs, rhsRoot, rhs)
  )
}

/**
 * A pointer-to-member operator as defined in [expr.mptr.oper] in N3797.
 *
 * This includes:
 * - `pm-expression .* cast-expression`
 * - `pm-expression ->* cast-expression`
 */
class PointerToMemberExpr extends Expr {
  PointerToMemberType pointerToMemberType;
  Expr pointerExpr;
  Expr objectExpr;

  PointerToMemberExpr() {
    objectExpr = this.(VariableCall).getExpr() and
    pointerExpr = this.(VariableCall).getQualifier() and
    pointerExpr.getUnderlyingType() = pointerToMemberType and
    pointerToMemberType.getBaseType() instanceof RoutineType
    or
    objectExpr = this.(VariableAccess).getQualifier() and
    pointerExpr = this and
    pointerExpr.(VariableAccess).getTarget().getUnderlyingType() = pointerToMemberType and
    not pointerToMemberType.getBaseType() instanceof RoutineType
  }

  /**
   * Gets the cast-expression part of the pointer-to-member expression.
   * In other words, the pointer pointing to a member.
   */
  Expr getPointerExpr() { result = pointerExpr }

  /**
   * Gets the pm-expression part of the pm-expression.
   * In other words, the object to which the second operand, the pointer to member, is bound to.
   */
  Expr getObjectExpr() { result = objectExpr }
}

/** A module containing classes and predicates to reason about Misra specific expression. */
module MisraExpr {
  private predicate isCValue(Expr e) {
    not e.isConstant() and
    (
      exists(ReturnStmt return | e = return.getExpr().getExplicitlyConverted())
      or
      exists(FunctionCall call | e = call.getAnArgument().getExplicitlyConverted())
    )
    or
    isCValue(e.(ParenthesisExpr).getExpr())
    or
    e instanceof CrementOperation
    or
    e instanceof UnaryMinusExpr
    or
    e instanceof NotExpr
    or
    e instanceof ComplementExpr
    or
    e instanceof MulExpr
    or
    e instanceof DivExpr
    or
    e instanceof RemExpr
    or
    e instanceof AddExpr
    or
    e instanceof SubExpr
    or
    e instanceof ComparisonOperation
    or
    e instanceof BinaryBitwiseOperation
    or
    e instanceof BinaryLogicalOperation
    or
    e instanceof ConditionalExpr
    or
    e instanceof CommaExpr
  }

  /** A cvalue as defined in the Misra C++:2008 standard. */
  class CValue extends Expr {
    CValue() { isCValue(this) }
  }
}

/**
 * An optimized set of expressions used to determine the flow through constexpr variables.
 */
class VariableAccessOrCallOrLiteral extends Expr {
  VariableAccessOrCallOrLiteral() {
    this instanceof VariableAccess and this.(VariableAccess).getTarget().isConstexpr()
    or
    this instanceof Call
    or
    this instanceof Literal
  }
}

/**
 * Holds if the value of source flows through compile time evaluated variables to target.
 */
predicate flowsThroughConstExprVariables(
  VariableAccessOrCallOrLiteral source, VariableAccessOrCallOrLiteral target
) {
  (
    source = target
    or
    source != target and
    exists(SsaDefinition intermediateDef, StackVariable intermediate |
      intermediateDef.getAVariable().getFunction() = source.getEnclosingFunction() and
      intermediateDef.getAVariable().getFunction() = target.getEnclosingFunction() and
      intermediateDef.getAVariable() = intermediate and
      intermediate.isConstexpr()
    |
      DataFlow::localExprFlow(source, intermediateDef.getDefiningValue(intermediate)) and
      flowsThroughConstExprVariables(intermediateDef.getAUse(intermediate), target)
    )
  )
}

predicate isCompileTimeEvaluatedExpression(Expr expression) {
  forall(DataFlow::Node ultimateSource, DataFlow::Node source |
    source = DataFlow::exprNode(expression) and
    DataFlow::localFlow(ultimateSource, source) and
    not DataFlow::localFlowStep(_, ultimateSource)
  |
    isDirectCompileTimeEvaluatedExpression(ultimateSource.asExpr()) and
    // If the ultimate source is not the same as the source, then it must flow through
    // constexpr variables.
    (
      ultimateSource != source
      implies
      flowsThroughConstExprVariables(ultimateSource.asExpr(), source.asExpr())
    )
  )
}

predicate isDirectCompileTimeEvaluatedExpression(Expr expression) {
  expression instanceof Literal
  or
  any(Call c | isCompileTimeEvaluatedCall(c)) = expression
}

/*
 * Returns true if the given call may be evaluated at compile time and is compile time evaluated because
 * all its arguments are compile time evaluated and its default values are compile time evaluated.
 */

predicate isCompileTimeEvaluatedCall(Call call) {
  // 1. The call may be evaluated at compile time, because it is constexpr, and
  call.getTarget().isConstexpr() and
  // 2. all its arguments are compile time evaluated, and
  forall(Expr argSource | argSource = call.getAnArgument() |
    isCompileTimeEvaluatedExpression(argSource)
  ) and
  // 3. all the default values used are compile time evaluated.
  forall(Expr defaultValue, Parameter parameterUsingDefaultValue, int idx |
    parameterUsingDefaultValue = call.getTarget().getParameter(idx) and
    not exists(call.getArgument(idx)) and
    parameterUsingDefaultValue.getAnAssignedValue() = defaultValue
  |
    isDirectCompileTimeEvaluatedExpression(defaultValue)
  ) and
  // 4. the call's qualifier is compile time evaluated.
  (not call.hasQualifier() or isCompileTimeEvaluatedExpression(call.getQualifier()))
}

/*
 * an operator that does not evaluate its operand
 */

class UnevaluatedExprExtension extends Expr {
  UnevaluatedExprExtension() {
    this.getAChild().isUnevaluated()
    or
    exists(FunctionCall declval |
      declval.getTarget().hasQualifiedName("std", "declval") and
      declval.getAChild() = this
    )
  }
}

/** A class representing left and right bitwise shift operations. */
class BitShiftExpr extends BinaryBitwiseOperation {
  BitShiftExpr() {
    this instanceof LShiftExpr or
    this instanceof RShiftExpr
  }
}
