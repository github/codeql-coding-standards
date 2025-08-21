/**
 * @id cpp/misra/no-implicit-bool-conversion
 * @name RULE-7-0-2: There shall be no conversion to type bool
 * @description Implicit and contextual conversions to bool from fundamental types, unscoped enums,
 *              or pointers may lead to unintended behavior, except for specific cases like pointer
 *              checks and explicit operator bool conversions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-0-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

predicate isInContextualBoolContext(Expr expr) {
  exists(IfStmt ifStmt | ifStmt.getCondition() = expr) or
  exists(WhileStmt whileStmt | whileStmt.getCondition() = expr) or
  exists(ForStmt forStmt | forStmt.getCondition() = expr) or
  exists(DoStmt doStmt | doStmt.getCondition() = expr) or
  exists(ConditionalExpr condExpr | condExpr.getCondition() = expr) or
  exists(LogicalAndExpr logicalAnd | logicalAnd.getAnOperand() = expr) or
  exists(LogicalOrExpr logicalOr | logicalOr.getAnOperand() = expr) or
  exists(NotExpr notExpr | notExpr.getOperand() = expr)
}

predicate isInWhileConditionDeclaration(Expr expr) {
  exists(WhileStmt whileStmt, ConditionDeclExpr condDecl |
    whileStmt.getCondition() = condDecl and
    condDecl.getExpr() = expr
  )
}

predicate isBitFieldOfSizeOne(Expr expr) {
  exists(BitField bf |
    expr = bf.getAnAccess() and
    bf.getNumBits() = 1
  )
}

predicate isPointerType(Type t) {
  t.getUnspecifiedType() instanceof PointerType or
  t.getUnspecifiedType() instanceof PointerToMemberType or
  t.getUnspecifiedType() instanceof NullPointerType
}

from Element e, string reason
where
  not isExcluded(e, ConversionsPackage::noImplicitBoolConversionQuery()) and
  (
    // Conversions to bool
    exists(Conversion conv |
      e = conv and
      conv.getType().getUnspecifiedType() instanceof BoolType and
      not conv.getExpr().getType().getUnspecifiedType() instanceof BoolType and
      // Exception 2: Contextual conversion from pointer
      not (
        isPointerType(conv.getExpr().getType()) and
        // Checks if the unconverted expression for this conversion is in a contextual bool context
        // This handles the cases where we have multiple stacked conversions, e.g. when converting
        // an array to a pointer, then the pointer to bool
        isInContextualBoolContext(conv.getUnconverted())
      ) and
      // Exception 3: Unconverted expression is a bit-field of size 1
      not isBitFieldOfSizeOne(conv.getUnconverted()) and
      // Exception 4: Unconverted expression is in a while condition declaration
      not isInWhileConditionDeclaration(conv.getUnconverted()) and
      reason = "Conversion from '" + conv.getExpr().getType().toString() + "' to 'bool'"
    )
    or
    // Calls to conversion operators to bool
    //
    // Note: we flag these separately because:
    // 1. If the conversion via the operator is implicit, there is no `Conversion` - only a call to
    //     the `ConversionOperator`.
    // 2. If the conversion is explicit, the `Conversion` is from `bool` to `bool`, which is not
    //    flagged in the previous `Conversion` case above.
    exists(Call conversionCall, ConversionOperator op |
      e = conversionCall and
      conversionCall.getTarget() = op and
      op.getType().getUnspecifiedType() instanceof BoolType and
      // Exception 1: Static cast to bool from class with explicit operator bool
      not exists(StaticCast conv |
        op.isExplicit() and
        conv.getExpr() = conversionCall and
        conv.getType().getUnspecifiedType() instanceof BoolType
      ) and
      // Exception 2: Contextual conversion from class with explicit operator bool is allowed
      not (
        op.isExplicit() and
        isInContextualBoolContext(conversionCall.getUnconverted())
      ) and
      reason =
        "Conversion operator call from '" + conversionCall.getQualifier().getType().toString() +
          "' to 'bool'"
    )
  )
select e, reason + "."
