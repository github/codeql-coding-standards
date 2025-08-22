/**
 * A module for finding objects and subobjects in C++ code.
 * 
 * Note that a C version of this module exists in `c/common`, as C has different semantics.
 */
import cpp

/**
 * Find the object types that are embedded within the current type.
 *
 * For example, a block of memory with type `T[]` has subobjects of type `T`, and a struct with a
 * member of `T member;` has a subobject of type `T`.
 *
 * Note that subobjects may be pointers, but the value they point to is not a subobject. For
 * instance, `struct { int* x; }` has a subobject of type `int*`, but not `int`.
 */
Type getADirectSubobjectType(Type type) {
  result = type.stripTopLevelSpecifiers().(Class).getAMemberVariable().getType()
  or
  result = type.stripTopLevelSpecifiers().(ArrayType).getBaseType()
}