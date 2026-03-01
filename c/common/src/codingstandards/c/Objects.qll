import cpp
import codingstandards.cpp.lifetimes.StorageDuration
import codingstandards.c.IdentifierLinkage
import semmle.code.cpp.valuenumbering.HashCons
import codingstandards.cpp.Clvalues

/**
 * A libary for handling "Objects" in C.
 *
 * Objects may be stored in registers or memory, they have an address, a type, a storage duration,
 * and a lifetime (which is different than storage duration). Objects which are structs or arrays
 * have subobjects, which share the storage duration and lifetime of the parent object.
 *
 * Note: lifetime analysis is not performed in this library, but is available in
 * the module `codingstandards.cpp.lifetimes.LifetimeProfile`. In the future, these libraries could
 * be merged for more complete analysis.
 *
 * To get objects in a project, use the `ObjectIdentity` class which finds the following types of
 * objects:
 * - global variables
 * - local variables
 * - literals
 * - malloc calls
 * - certain temporary object expressions
 *
 * And direct references to these objects can be found via the member predicate `getAnAccess()`.
 * However, much of a project's code will not refer to these objects directly, but rather, refer to
 * their subobjects. The class `ObjectIdentity` exposes several member predicates for finding when
 * these subobjects are used:
 * - `getASubobjectType()`
 * - `getASubobjectAccess()`
 * - `getASubobjectAddressExpr()`
 *
 * These methods do not use flow analysis, and will not return a conclusive list of accesses. To
 * get better results here, this library should be integrated with flow analysis or the library
 * `LifetimeProfile.qll`.
 *
 * Additionally, subobjects are currently not tracked individually. In the future subobjects could
 * be tracked as a root object and an access chain to refer to them. For now, however, finding *any*
 * subobject access is sufficient for many analyses.
 *
 * To get the storage duration, `ObjectIdentity` exposes the member predicate
 * `getStorageDuration()` with the following options:
 * - `obj.getStorageDuration().isAutomatic()`: Stack objects
 * - `obj.getStorageDuration().isStatic()`: Global objects
 * - `obj.getStorageDuration().isThread()`: Threadlocal objects
 * - `obj.getStorageDuration().isAllocated()`: Dynamic objects
 *
 * Note that lifetimes are not storage durations. The only lifetime tracking currently implemented
 * is `hasTemporaryLifetime()`, which is a subset of automatic storage duration objects, and may
 * be filtered out, or selected directly with `TemporaryObjectIdentity`.
 */
final class ObjectIdentity = ObjectIdentityBase;

/**
 * A base class for objects in C, along with the source location where the object can be identified
 * in the project code (thus, this class extends `Element`), which may be variable, or may be an
 * expression such as a literal or a malloc call.
 *
 * Extend this class to define a new type of object identity. To create a class which filters the
 * set of object identities, users of this library should extend the final subclass
 * `ObjectIdentity` instead.
 */
abstract class ObjectIdentityBase extends Element {
  /**
   * The type of this object.
   *
   * Note that for allocated objects, this is inferred from the sizeof() statement or the variable
   * it is assigned to.
   */
  abstract Type getType();

  /* The storage duration of this object: static, thread, automatic, or allocated. */
  abstract StorageDuration getStorageDuration();

  /**
   * Get the nested objects within this object (members, array element types).
   *
   * Note that if a struct has a pointer member, the pointer itself is a subobject, but the value
   * it points to is not. Therefore `struct { int* x; }` has a subobject of type `int*`, but not
   * `int`.
   */
  Type getASubObjectType() { result = getADirectSubobjectType*(getType()) }

  /**
   * Get expressions which trivially access this object. Does not perform flow analysis.
   *
   * For dynamically allocated objects, this is a dereference of the malloc call.
   */
  abstract Expr getAnAccess();

  /**
   * Get expressions which trivially access this object or a subobject of this object. Does not
   * perform flow analysis.
   *
   * For dynamically allocated objects, this is a dereference of the malloc call or direct access
   * of the result of dereferencing the malloc call.
   */
  Expr getASubobjectAccess() { result = getASubobjectAccessOf(getAnAccess()) }

  /**
   * Get expressions which trivially take the address of this object or a subobject of this object.
   * Does not perform flow analysis.
   */
  Expr getASubobjectAddressExpr() {
    exists(Expr subobject |
      subobject = getASubobjectAccess() and
      (
        // Holds for address-of expressions.
        result = any(AddressOfExpr e | e.getOperand() = subobject)
        or
        // Holds for array-to-pointer conversions, which evaluate to a usable subobject address.
        exists(ArrayToPointerConversion c | c.getExpr() = subobject) and
        // Note that `arr[x]` has an array-to-pointer conversion, and returns the `x`th item by
        // value, not the address of the `x`th item. Therefore, exclude `arr` if `arr` is part of
        // an expression `arr[x]`.
        not exists(ArrayExpr a | a.getArrayBase() = subobject) and
        result = subobject
      )
    )
  }

  /**
   * Holds if the object has temporary lifetime. This is not a storage duration, but only objects
   * with automatic storage duration have temporary lifetime.
   */
  abstract predicate hasTemporaryLifetime();
}

/**
 * Finds expressions `e.x` or `e[x]` for expression `e`, recursively. Does not resolve pointers.
 *
 * Note that this does not hold for `e->x` or `e[x]` where `e` is a pointer.
 */
private Expr getASubobjectAccessOf(Expr e) {
  result = e
  or
  result.(DotFieldAccess).getQualifier() = getASubobjectAccessOf(e)
  or
  result.(ArrayExpr).getArrayBase() = getASubobjectAccessOf(e) and
  not result.(ArrayExpr).getArrayBase().getUnspecifiedType() instanceof PointerType
}

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
  result = type.stripTopLevelSpecifiers().(Struct).getAMember().getADeclarationEntry().getType()
  or
  result = type.stripTopLevelSpecifiers().(ArrayType).getBaseType()
}

/**
 * An object in memory which may be identified by the variable that holds it.
 *
 * This may be a local variable, a global variable, or a parameter, etc. However, it cannot be a
 * member of a struct or union, as these do not have storage duration.
 */
class VariableObjectIdentity extends Variable, ObjectIdentityBase {
  VariableObjectIdentity() {
    // Exclude members; member definitions does not allocate storage and thus do not have a storage
    // duration. They are therefore not objects. To get the storage duration of members, use one of
    // the predicates related to sub objects, e.g. `getASubObjectType()`.
    not isMember()
  }

  override StorageDuration getStorageDuration() {
    // 6.2.4.4, objects declared _Thread_local have thread storage duration.
    isThreadLocal() and result.isThread()
    or
    // 6.2.4.3, Non _ThreadLocal objects with internal or external linkage or declared static have
    // static storage duration.
    not isThreadLocal() and
    (hasLinkage() or isStatic()) and
    result.isStatic()
    or
    // 6.2.4.3, Non _ThreadLocal objects no linkage that are not static have automatic storage
    // duration.
    not isThreadLocal() and
    not hasLinkage() and
    not isStatic() and
    result.isAutomatic()
  }

  override Type getType() {
    // Caution here: If we use `Variable.super.getType()` then override resolution is skipped, and
    // it uses the base predicate defined as `none()`. By casting this to `Variable` and calling
    // `getType()`, all overrides (harmlessly, *including this one*...) are considered, which means
    // we defer to the subclasses such as `GlobalVariable` overrides of `getType()`, which is what
    // we want.
    result = this.(Variable).getType()
  }

  /* The storage duration of a variable depends on its linkage. */
  IdentifierLinkage getLinkage() { result = linkageOfVariable(this) }

  predicate hasLinkage() { not getLinkage().isNone() }

  override VariableAccess getAnAccess() { result = Variable.super.getAnAccess() }

  override predicate hasTemporaryLifetime() {
    none() // Objects identified by a variable do not have temporary lifetime.
  }
}

/**
 * A string literal is an object with static storage duration.
 *
 * 6.4.5.6, multibyte character sequences initialize an array of static storage duration.
 */
class LiteralObjectIdentity extends Literal, ObjectIdentityBase {
  override StorageDuration getStorageDuration() { result.isStatic() }

  override Type getType() { result = Literal.super.getType() }

  override Expr getAnAccess() { result = this }

  override predicate hasTemporaryLifetime() {
    none() // String literal objects do not have temporary lifetime.
  }
}

/**
 * An object identifiable as a struct or array literal, which is an lvalue that may have static or
 * automatic storage duration depending on context.
 *
 * 6.5.2.5.5, compound literals outside of a function have static storage duration, while literals
 * inside a function have automatic storage duration.
 */
class AggregateLiteralObjectIdentity extends AggregateLiteral, ObjectIdentityBase {
  override StorageDuration getStorageDuration() {
    if exists(getEnclosingFunction()) then result.isAutomatic() else result.isStatic()
  }

  override Type getType() { result = AggregateLiteral.super.getType() }

  override Expr getAnAccess() { result = this }

  override predicate hasTemporaryLifetime() {
    // Confusing; a struct literal is an lvalue, and therefore does not have temporary lifetime.
    none()
  }
}

/**
 * An object identified by a call to `malloc`.
 *
 * Note: the malloc expression returns an address to this object, not the object itself. Therefore,
 * `getAnAccess()` returns cases where this malloc result is dereferenced, and not the malloc call
 * itself.
 *
 * Note that the predicates for tracking accesses, subobject accesses, and address expresisons may
 * be less reliable as dynamic memory is fundamentally more difficult to track. However, this class
 * attempts to give reasonable results. In the future, this could be improved by integrating with
 * LifetimeProfile.qll or by integrating flow analysis.
 *
 * Additionally, the type of this object is inferred based on its size and use.
 */
class AllocatedObjectIdentity extends AllocationExpr, ObjectIdentityBase {
  AllocatedObjectIdentity() {
    this.(FunctionCall).getTarget().(AllocationFunction).requiresDealloc()
  }

  override StorageDuration getStorageDuration() { result.isAllocated() }

  /** Attempt to infer the type of the allocated memory */
  override Type getType() { result = this.getAllocatedElementType() }

  /** Find dereferences of direct aliases of this pointer result. */
  override Expr getAnAccess() { result.(PointerDereferenceExpr).getOperand() = getAnAlias() }

  /**
   * Find the following subobject accesses, given a pointer alias `x`:
   * - `(*x)`
   * - `(*x).y`
   * - `(*x)[i]`
   * - `x->y`
   * - `x[i]`
   * - `x->y.z`
   * - `x[i].y`
   * - all direct accesses (`foo.x`, `foo[i]`) of the above
   */
  override Expr getASubobjectAccess() {
    result = getASubobjectAccessOf(getAnAccess())
    or
    exists(PointerFieldAccess pfa |
      pfa.getQualifier() = getASubobjectAddressExpr() and
      result = getASubobjectAccessOf(pfa)
    )
    or
    exists(ArrayExpr arrayExpr |
      arrayExpr.getArrayBase() = getASubobjectAddressExpr() and
      result = getASubobjectAccessOf(arrayExpr)
    )
  }

  /**
   * Given a pointer alias `x`, finds `x` itself. Additionally, defers to the default class
   * behavior, which finds address-of (`&`) and array-to-pointer conversions of all subobject
   * accesses. (See `AllocatedObjectIdentity.getASubobjectAccess()`.)
   */
  override Expr getASubobjectAddressExpr() {
    result = getAnAlias()
    or
    result = super.getASubobjectAddressExpr()
  }

  /**
   * Find an obvious direct reference to the result of a `malloc()` function call. This includes
   * the function call itself, but additionally:
   * - For `T* x = malloc(...)`, accesses to variable `x` are likely aliases of the malloc result
   * - For `(expr) = malloc(...)` future lexically identical uses of `expr` are likely aliases of
   *   the malloc result.
   *
   * This is used so that member predicates such as `getAnAccess()`, `getASubobjectAccess()` can
   * find cases such as:
   *
   * ```c
   *   int *x = malloc(sizeof(int));
   *   return *x; // accesses the malloc result
   * ```
   */
  Expr getAnAlias() {
    result = this
    or
    exists(AssignExpr assignExpr |
      assignExpr.getRValue() = this and
      hashCons(result) = hashCons(assignExpr.getLValue())
    )
    or
    exists(Variable v |
      v.getInitializer().getExpr() = this and
      result = v.getAnAccess()
    )
  }

  override predicate hasTemporaryLifetime() {
    none() // Allocated objects do not have "temporary lifetime."
  }
}

/**
 * A struct or union type that contains an array type, used to find objects with temporary
 * lifetime.
 */
private class StructOrUnionTypeWithArrayField extends Struct {
  StructOrUnionTypeWithArrayField() {
    this.getAField().getUnspecifiedType() instanceof ArrayType
    or
    // nested struct or union containing an array type
    this.getAField().getUnspecifiedType().(Struct) instanceof StructOrUnionTypeWithArrayField
  }
}

/**
 * 6.2.4.7, A non-lvalue expression with struct or or union type that has a field member of array
 * type, refers to an object with automatic storage duration (and has temporary lifetime).
 *
 * The spec uses the lanugage "refers to." This is likely intended to mean that the expression
 * `foo().x` does not create a new temporary object, but rather "refers to" the temporary object
 * storing the value of the expression `foo()`.
 *
 * Separate this predicate to avoid non-monotonic recursion (`C() { not exists(C c | ... ) }`).
 */
private class TemporaryObjectIdentityExpr extends Expr {
  TemporaryObjectIdentityExpr() {
    getType() instanceof StructOrUnionTypeWithArrayField and
    not isCLValue(this)
  }
}

/**
 * 6.2.4.7, A non-lvalue expression with struct or or union type that has a field member of array
 * type, is an object with automatic storage duration (and has temporary lifetime).
 */
class TemporaryObjectIdentity extends ObjectIdentityBase instanceof TemporaryObjectIdentityExpr {
  TemporaryObjectIdentity() {
    // See comment in `TemporaryObjectIdentityExpr` for why we check `getASubobjectAccess()` here.
    not exists(TemporaryObjectIdentityExpr parent |
      this = getASubobjectAccessOf(parent) and
      not this = parent
    )
  }

  override StorageDuration getStorageDuration() { result.isAutomatic() }

  override Type getType() { result = this.(Expr).getType() }

  override Expr getAnAccess() { result = this }

  override predicate hasTemporaryLifetime() { any() }
}
