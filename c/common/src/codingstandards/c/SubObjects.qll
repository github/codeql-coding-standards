import codingstandards.c.Objects

newtype TSubObject =
  TObjectRoot(ObjectIdentity i) or
  TObjectMember(SubObject struct, MemberVariable m) {
    m = struct.getType().(Struct).getAMemberVariable()
  } or
  TObjectIndex(SubObject array) { array.getType() instanceof ArrayType }

class SubObject extends TSubObject {
  string toString() {
    exists(ObjectIdentity i |
      this = TObjectRoot(i) and
      result = i.toString()
    )
    or
    exists(SubObject struct, Variable m |
      this = TObjectMember(struct, m) and
      result = struct.toString() + "." + m.getName()
    )
    or
    exists(SubObject array |
      this = TObjectIndex(array) and
      result = array.toString()
    )
  }

  Type getType() {
    exists(ObjectIdentity i |
      this = TObjectRoot(i) and
      result = i.getType()
    )
    or
    exists(Variable m |
      this = TObjectMember(_, m) and
      result = m.getType()
    )
    or
    exists(SubObject array |
      this = TObjectIndex(array) and
      result = array.getType().(ArrayType).getBaseType()
    )
  }

  /**
   * Holds for object roots and for member accesses on that root, not for array accesses.
   * 
   * This is useful for cases where we do not wish to treat `x[y]` and `x[z]` as the same object.
   */
  predicate isPrecise() {
    not getParent*() = TObjectIndex(_)
  }

  SubObject getParent() {
    exists(SubObject struct, MemberVariable m |
      this = TObjectMember(struct, m) and
      result = struct
    )
    or
    exists(SubObject array |
      this = TObjectIndex(array) and
      result = array
    )
  }

  Expr getAnAccess() {
    exists(ObjectIdentity i |
      this = TObjectRoot(i) and
      result = i.getAnAccess()
    )
    or
    exists(MemberVariable m |
      this = TObjectMember(_, m) and
      result = m.getAnAccess() and
      result.(DotFieldAccess).getQualifier() = getParent().getAnAccess()
    )
    or
    this = TObjectIndex(_) and
    result.(ArrayExpr).getArrayBase() = getParent().getAnAccess()
  }

  AddressOfExpr getAnAddressOfExpr() {
    result.getOperand() = this.getAnAccess()
  }

  ObjectIdentity getRootIdentity() {
    exists(ObjectIdentity i |
      this = TObjectRoot(i) and
      result = i
    )
    or
    result = getParent().getRootIdentity()
  }
}
