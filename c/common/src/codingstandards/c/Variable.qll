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
  Struct s;

  FlexibleArrayMemberCandidate() {
    this.getType() instanceof ArrayType and
    this.getDeclaringType() = s and
    not exists(int i, int j |
      s.getAMember(i) = this and
      exists(s.getAMember(j)) and
      j > i
    )
  }
}
