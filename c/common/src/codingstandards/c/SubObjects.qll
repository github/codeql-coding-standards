/**
 * A library that expands upon the `Objects.qll` library, to support nested "Objects" such as
 * `x.y.z` or `x[i][j]` within an object `x`.
 *
 * Objects in C are values in memory, that have a type and a storage duration. In the case of
 * array objects and struct objects, the object will contain other objects. The these subobjects
 * will share properties of the root object such as storage duration. This library can be used to,
 * for instance, find all usages of a struct member to ensure that member is initialized before it
 * is used.
 *
 * To use this library, select `SubObject` and find its usages in the AST via `getAnAccess()` (to
 * find usages of the subobject by value) or `getAnAddressOfExpr()` (to find usages of the object
 * by address).
 *
 * Note that a struct or array object may contain a pointer. In this case, the pointer itself is
 * a subobject of the struct or array object, but the object that the pointer points to is not.
 * This is because the pointed-to object does not necessarily have the same storage duration,
 * lifetime, or linkage as the pointer and the object containing the pointer.
 *
 * Note as well that `getAnAccess()` on an array subobject will return all accesses to the array,
 * not just accesses to a particular index. For this reason, `SubObject` exposes the predicate
 * `isPrecise()`. If a subobject is precise, that means all results of `getAnAccess()` will
 * definitely refer to the same object in memory. If it is not precise, the different accesses
 * may refer to the same or different objects in memory. For instance, `x[i].y` and `x[j].y` are
 * the same object if `i` and `j` are the same, but they are different objects if `i` and `j` are
 * different.
 */

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
  predicate isPrecise() { not getParent*() = TObjectIndex(_) }

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
      // Only consider `DotFieldAccess`es, not `PointerFieldAccess`es, as the latter
      // are not subobjects of the root object:
      result.(DotFieldAccess).getQualifier() = getParent().getAnAccess()
    )
    or
    this = TObjectIndex(_) and
    result.(ArrayExpr).getArrayBase() = getParent().getAnAccess()
  }

  AddressOfExpr getAnAddressOfExpr() { result.getOperand() = this.getAnAccess() }

  /**
   * Get the "root" object identity to which this subobject belongs. For instance, in the
   * expression `x.y.z`, the root object is `x`. This subobject will share properties with the root
   * object such as storage duration, lifetime, and linkage.
   */
  ObjectIdentity getRootIdentity() {
    exists(ObjectIdentity i |
      this = TObjectRoot(i) and
      result = i
    )
    or
    result = getParent().getRootIdentity()
  }
}
