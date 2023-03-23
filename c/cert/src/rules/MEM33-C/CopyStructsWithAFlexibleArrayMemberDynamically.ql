/**
 * @id c/cert/copy-structs-with-a-flexible-array-member-dynamically
 * @name MEM33-C: Copy structures containing a flexible array member using memcpy or a similar function
 * @description Copying a structure containing a flexbile array member by assignment ignores the
 *              flexible array member data.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/mem33-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Variable
import semmle.code.cpp.security.BufferAccess

/**
 * An expanded variant of the CodeQL standard library `MemcpyBA`
 * class that additionally models the `__builtin___memcpy_chk` function.
 */
class MemcpyBAExpanded extends BufferAccess {
  MemcpyBAExpanded() {
    this.(FunctionCall).getTarget().getName() =
      ["memcmp", "wmemcmp", "_memicmp", "_memicmp_l", "__builtin___memcpy_chk"]
  }

  override string getName() { result = this.(FunctionCall).getTarget().getName() }

  override Expr getBuffer(string bufferDesc, int accessType) {
    result = this.(FunctionCall).getArgument(0) and
    bufferDesc = "destination buffer" and
    accessType = 2
    or
    result = this.(FunctionCall).getArgument(1) and
    bufferDesc = "source buffer" and
    accessType = 2
  }

  override int getSize() {
    result =
      this.(FunctionCall).getArgument(2).getValue().toInt() *
        getPointedSize(this.(FunctionCall).getTarget().getParameter(0).getType())
  }
}

/**
 * A class representing an `Expr` that copies a flexible array struct.
 */
abstract class FlexibleArrayCopyExpr extends Expr { }

/**
 * A simple assignment of a flexible array struct to another flexible array struct.
 */
class FlexibleArraySimpleCopyExpr extends FlexibleArrayCopyExpr {
  FlexibleArraySimpleCopyExpr() {
    exists(Variable v |
      this.getUnspecifiedType() instanceof FlexibleArrayStructType and
      (
        exists(Initializer init |
          init.getDeclaration() = v and
          init.getExpr() = this
        )
        or
        exists(AssignExpr assign |
          assign.getLValue().getUnspecifiedType() instanceof FlexibleArrayStructType and
          assign.getRValue() = this
        )
      )
    )
  }
}

/**
 * A call to a function that copies a flexible array struct.
 */
class FlexibleArrayMemcpyCallExpr extends FlexibleArrayCopyExpr, MemcpyBAExpanded {
  FlexibleArrayMemcpyCallExpr() {
    not exists(Expr e |
      e = this.getBuffer(_, _) and
      not e.getType().stripType() instanceof FlexibleArrayStructType
    )
  }

  /**
   * Holds if the size copied does not account for the flexible array member.
   */
  predicate isFlexibleArrayCopiedWithInsufficientSize() {
    this.getSize() <=
      max(this.getBuffer(_, _)
              .getUnderlyingType()
              .(DerivedType)
              .getBaseType()
              .getUnspecifiedType()
              .getSize()
      )
  }
}

from FlexibleArrayCopyExpr faCopy, string message
where
  not isExcluded(faCopy, Memory2Package::copyStructsWithAFlexibleArrayMemberDynamicallyQuery()) and
  (
    // case 1: simple assignment
    faCopy instanceof FlexibleArraySimpleCopyExpr and
    message = "Struct containing a flexible array member copied by assignment."
    or
    // case 2: call to memcpy
    faCopy.(FlexibleArrayMemcpyCallExpr).isFlexibleArrayCopiedWithInsufficientSize() and
    message =
      "Struct containing a flexible array member copied by call to memcpy with insufficient size."
  )
select faCopy, message
