/**
 * @id c/cert/do-not-access-volatile-object-with-non-volatile-reference
 * @name EXP32-C: Do not access a volatile object through a nonvolatile reference
 * @description If an an object defined with a volatile-qualified type is referred to with an lvalue
 *              of a non-volatile-qualified type, the behavior is undefined.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp32-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/**
 * A `Cast` which converts from a pointer to a volatile-qualified type
 * to a pointer to a non-volatile-qualified type.
 */
class CastFromVolatileToNonVolatileBaseType extends Cast {
  CastFromVolatileToNonVolatileBaseType() {
    this.getExpr().getType().(PointerType).getBaseType*().isVolatile() and
    this.getActualType() instanceof PointerType and
    not this.getActualType().(PointerType).getBaseType*().isVolatile()
  }
}

/**
 * An `AssignExpr` with an *lvalue* that is a pointer to a volatile base type and
 * and *rvalue* that is not also a pointer to a volatile base type.
 */
class NonVolatileObjectAssignedToVolatilePointer extends AssignExpr {
  NonVolatileObjectAssignedToVolatilePointer() {
    this.getLValue().getType().(DerivedType).getBaseType*().isVolatile() and
    not this.getRValue().getUnconverted().getType().(DerivedType).getBaseType*().isVolatile()
  }

  /**
   * All `VariableAccess` expressions which are transitive successors of
   * this `Expr` and which access the variable accessed in the *rvalue* of this `Expr`
   */
  Expr getASubsequentAccessOfAssignedObject() {
    result =
      any(VariableAccess va |
        va = this.getRValue().getAChild*().(VariableAccess).getTarget().getAnAccess() and
        this.getASuccessor+() = va
      |
        va
      )
  }
}

from Expr e, string message
where
  not isExcluded(e, Pointers3Package::doNotAccessVolatileObjectWithNonVolatileReferenceQuery()) and
  (
    e instanceof CastFromVolatileToNonVolatileBaseType and
    message = "Cast of object with a volatile-qualified type to a non-volatile-qualified type."
    or
    exists(e.(NonVolatileObjectAssignedToVolatilePointer).getASubsequentAccessOfAssignedObject()) and
    message =
      "Non-volatile object referenced via pointer to volatile type and later accessed via its original object of a non-volatile-qualified type."
  )
select e, message
