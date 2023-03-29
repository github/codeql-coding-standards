import cpp

class VlaVariable extends Variable {
  VlaVariable() { exists(VlaDeclStmt s | s.getVariable() = this) }

  /* Extractor workaround do determine if a VLA array has the specifier volatile.*/
  override predicate isVolatile() { this.getType().(ArrayType).getBaseType().isVolatile() }
}

/**
 * A flexible array member
 * ie member with the type array that is last in a struct
 * has no size specified
 */
class FlexibleArrayMember extends FlexibleArrayMemberCandidate {
  FlexibleArrayMember() {
    exists(ArrayType t |
      this.getType() = t and
      not exists(t.getSize())
    )
  }
}

/**
 * A member with the type array that is last in a struct
 * includes any sized array (either specified or not)
 */
class FlexibleArrayMemberCandidate extends MemberVariable {
  FlexibleArrayMemberCandidate() {
    this.getType() instanceof ArrayType and
    exists(Struct s |
      this.getDeclaringType() = s and
      not exists(int i, int j |
        s.getAMember(i) = this and
        exists(s.getAMember(j)) and
        j > i
      )
    )
  }
}

/**
 * Returns the target variable of a `VariableAccess`.
 * If the access is a field access, then the target is the `Variable` of the qualifier.
 * If the access is an array access, then the target is the array base.
 */
Variable getAddressOfExprTargetBase(AddressOfExpr expr) {
  result = expr.getOperand().(ValueFieldAccess).getQualifier().(VariableAccess).getTarget()
  or
  not expr.getOperand() instanceof ValueFieldAccess and
  result = expr.getOperand().(VariableAccess).getTarget()
  or
  result = expr.getOperand().(ArrayExpr).getArrayBase().(VariableAccess).getTarget()
}

/**
 * A struct that contains a flexible array member
 */
class FlexibleArrayStructType extends Struct {
  FlexibleArrayMember member;

  FlexibleArrayStructType() { this = member.getDeclaringType() }

  FlexibleArrayMember getFlexibleArrayMember() { result = member }
}
