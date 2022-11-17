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
import semmle.code.cpp.controlflow.Dereferenced
import semmle.code.cpp.controlflow.StackVariableReachability

abstract class UndefinedVolatilePointerExpr extends Expr {
  abstract string getMessage();
}

/**
 * Gets the depth of a pointer's base type's volatile qualifier
 */
int getAVolatileDepth(PointerType pt) {
  pt.getBaseType().isVolatile() and result = 1
  or
  result = getAVolatileDepth(pt.getBaseType()) + 1
}

/**
 * A `Cast` which converts from a pointer to a volatile-qualified type
 * to a pointer to a non-volatile-qualified type.
 */
class CastFromVolatileToNonVolatileBaseType extends Cast, UndefinedVolatilePointerExpr {
  CastFromVolatileToNonVolatileBaseType() {
    exists(int i |
      i = getAVolatileDepth(this.getExpr().getType()) and
      not i = getAVolatileDepth(this.getActualType())
    )
  }

  override string getMessage() {
    result = "Cast of object with a volatile-qualified type to a non-volatile-qualified type."
  }
}

/**
 * An `AssignExpr` with an *lvalue* that is a pointer to a volatile base type and
 * and *rvalue* that is not also a pointer to a volatile base type.
 */
class NonVolatileObjectAssignedToVolatilePointer extends AssignExpr, UndefinedVolatilePointerExpr {
  NonVolatileObjectAssignedToVolatilePointer() {
    exists(int i |
      not i = getAVolatileDepth(this.getRValue().getType()) and
      i = getAVolatileDepth(this.getLValue().(VariableAccess).getTarget().getType())
    ) and
    exists(VariableAccess va |
      va = this.getRValue().getAChild*().(VariableAccess).getTarget().getAnAccess() and
      this.getASuccessor+() = va
    )
  }

  override string getMessage() {
    result =
      "Assignment indicates a volatile object, but a later access of the object occurs via a non-volatile pointer."
  }
}

from UndefinedVolatilePointerExpr e
where not isExcluded(e, Pointers3Package::doNotAccessVolatileObjectWithNonVolatileReferenceQuery())
select e, e.getMessage()
