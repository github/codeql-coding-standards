import cpp
import Expr

/**
 * any assignment operator that also reads from the access
 */
class AnyAssignOperation extends Expr {
  AnyAssignOperation() {
    this instanceof AssignOperation
    or
    // operator op, where op is +=, -=, *=, /=, %=, ^=, &=, |=, >>=, <<=
    exists(string op |
      "operator" + op = this.(FunctionCall).getTarget().getName() and
      op in ["+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", ">>=", "<<="]
    )
  }
}

/** A copy assignment operator. */
class CopyOperator extends MemberFunction {
  CopyOperator() {
    exists(Type classType, Parameter p |
      this.getDeclaringType().getUnderlyingType() = classType and p = this.getAParameter()
    |
      this.getNumberOfParameters() = 1 and
      this.hasName("operator=") and
      (
        p.getUnspecifiedType().getUnderlyingType() = classType or
        p.getUnspecifiedType()
            .(LValueReferenceType)
            .getBaseType()
            .getUnspecifiedType()
            .getUnderlyingType() = classType
      ) and
      this.getType().(ReferenceType).getBaseType().getUnderlyingType() = classType
    )
  }
}

/** A user implemented copy assignment operator. */
class UserCopyOperator extends CopyOperator {
  UserCopyOperator() {
    exists(this.getFile().getRelativePath()) and
    hasDefinition() and
    not isDeleted() and
    not isDefaulted() and
    not isCompilerGenerated() and
    exists(getBlock()) and
    not getBlock().getLocation().hasLocationInfo("", 0, 0, 0, 0)
  }
}

/** A move assignment operator. */
class MoveOperator extends MemberFunction {
  MoveOperator() {
    exists(Type classType, Parameter p |
      this.getDeclaringType().getUnderlyingType() = classType and p = this.getAParameter()
    |
      this.getNumberOfParameters() = 1 and
      this.hasName("operator=") and
      p.getUnspecifiedType()
          .(RValueReferenceType)
          .getBaseType()
          .getUnspecifiedType()
          .getUnderlyingType() = classType and
      this.getType().(ReferenceType).getBaseType().getUnderlyingType() = classType
    )
  }
}

/** A user implemented move assignment operator. */
class UserMoveOperator extends MoveOperator {
  UserMoveOperator() {
    exists(this.getFile().getRelativePath()) and
    hasDefinition() and
    not isDeleted() and
    not isDefaulted() and
    not isCompilerGenerated() and
    exists(getBlock()) and
    not getBlock().getLocation().hasLocationInfo("", 0, 0, 0, 0)
  }
}

/** An assignment to a field in the copy assignment operator where the assignment is a direct copy of the same field from the provided class instance. */
class CopyOperatorFieldCopyAssign extends AnyAssignExpr {
  CopyOperatorFieldCopyAssign() { exists(CopyOperator op | this = getAMemberCopyAssignment(op)) }
}

/** An assignment to a field in the move assignment operator where the assignment is a direct copy or move of the same field from the provided class instance. */
class MoveOperatorFieldCopyAssign extends AnyAssignExpr {
  MoveOperatorFieldCopyAssign() { exists(MoveOperator op | this = getAMemberMoveAssignment(op)) }
}

/** Re-initialize field of a class instance passed to a move assignment operator. */
class MoveOperatorFieldReset extends AnyAssignExpr {
  MoveOperatorFieldReset() {
    exists(MoveOperator op, Parameter other |
      op.getAParameter() = other and
      other.getUnspecifiedType().(RValueReferenceType).getBaseType().getUnspecifiedType() =
        op.getDeclaringType() and
      this.getEnclosingFunction() = op and
      other = this.getLValue().(ReferenceFieldAccess).getQualifier().(VariableAccess).getTarget()
    )
  }

  VariableAccess getLAccess() { result = this.getLValue() }
}

/** A user-defined assignment operator */
class UserAssignmentOperator extends AssignmentOperator {
  UserAssignmentOperator() {
    hasDefinition() and
    not isDeleted() and
    not isDefaulted() and
    not isCompilerGenerated() and
    exists(getBlock()) and
    not getBlock().getLocation().hasLocationInfo("", 0, 0, 0, 0)
  }
}

/** An assignment operator of any sort */
class AssignmentOperator extends MemberFunction {
  AssignmentOperator() {
    // operator op, where op is =, +=, -=, *=, /=, %=, ^=, &=, |=, >>=, <<=
    exists(string op |
      "operator" + op = this.getName() and
      op in ["=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", ">>=", "<<="]
    )
  }
}

class UserComparisonOperator extends Function {
  UserComparisonOperator() {
    exists(string op |
      "operator" + op = this.getName() and
      op in ["==", "!=", "<", ">", "<=", ">="]
    ) and
    (
      hasDefinition() and
      not isDeleted() and
      not isDefaulted() and
      not isCompilerGenerated() and
      exists(getBlock()) and
      not getBlock().getLocation().hasLocationInfo("", 0, 0, 0, 0)
    )
  }
}

class UserArithmeticOperator extends Function {
  UserArithmeticOperator() {
    exists(string op |
      "operator" + op = this.getName() and
      op in ["+", "-", "/", "*", "%"]
    ) and
    (
      hasDefinition() and
      not isDeleted() and
      not isDefaulted() and
      not isCompilerGenerated() and
      exists(getBlock()) and
      not getBlock().getLocation().hasLocationInfo("", 0, 0, 0, 0)
    )
  }
}

class UserBitwiseOperator extends Function {
  UserBitwiseOperator() {
    exists(string op |
      "operator" + op = this.getName() and
      op in ["&", "|", "^", "~", "%", "<<", ">>"]
    ) and
    not this.isCompilerGenerated() and
    not this.getType().(ReferenceType).getBaseType().hasName("ostream") and
    not this.getType().(ReferenceType).getBaseType().hasName("istream")
  }
}

class FunctionCallOperator extends Function {
  FunctionCallOperator() { this.hasName("operator()") }
}

class UserCopyOrUserMoveOperator extends Operator {
  UserCopyOrUserMoveOperator() {
    (
      this instanceof UserCopyOperator
      or
      this instanceof UserMoveOperator
    ) and
    (
      hasDefinition() and
      not isDeleted() and
      not isDefaulted() and
      not isCompilerGenerated() and
      exists(getBlock()) and
      not getBlock().getLocation().hasLocationInfo("", 0, 0, 0, 0)
    )
  }
}

class StarOperator extends Operator {
  StarOperator() {
    hasName("operator*") and
    getNumberOfParameters() = 0
  }
}

class IncrementOperator extends Operator {
  IncrementOperator() {
    hasName("operator++") and
    getNumberOfParameters() = 0
  }
}

class StructureDerefOperator extends Operator {
  StructureDerefOperator() {
    hasName("operator->") and
    getNumberOfParameters() = 0
  }
}

class SubscriptOperator extends Operator {
  SubscriptOperator() {
    hasName("operator[]") and
    getNumberOfParameters() = 1
  }
}

/** A user defined operator for `++` and `--`. */
class UserCrementOperator extends Operator {
  UserCrementOperator() {
    exists(string op | op in ["++", "--"] | "operator" + op = this.getName())
  }
}

/** A user defined negation operator. */
class UserNegationOperator extends Operator {
  UserNegationOperator() { hasName("operator!") }
}

/** A user defined operator for `==` and `!=`. */
class UserEqualityOperator extends Operator {
  boolean polarity;

  UserEqualityOperator() {
    "operator==" = this.getName() and polarity = true
    or
    "operator!=" = this.getName() and polarity = false
  }

  /** Gets the polarity of the operator, which is true in the case of `==` and false in the case of `!=`. */
  boolean getPolarity() { result = polarity }
}

class UserOverloadedOperator extends Function {
  UserOverloadedOperator() {
    exists(string op |
      "operator" + op = this.getName() and
      op in [
          "+", "-", "*", "/", "%", "^", "&", "|", "~", "!", "=", "<", ">", "+=", "-=", "*=", "/=",
          "%=", "^=", "&=", "|=", "<<", ">>", ">>=", "<<=", "==", "!=", "<=", ">=", "<=>", "&&",
          "||", "++", "--", "->*", "->", "()", "[]"
        ]
    ) and
    not this.isCompilerGenerated()
  }
}
