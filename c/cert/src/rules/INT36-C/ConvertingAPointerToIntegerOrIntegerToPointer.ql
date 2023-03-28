/**
 * @id c/cert/converting-a-pointer-to-integer-or-integer-to-pointer
 * @name INT36-C: Do not convert pointers to integers and back
 * @description Converting between pointers and integers is not portable and might cause invalid
 *              memory access.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/int36-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

class LiteralZero extends Literal {
  LiteralZero() { this.getValue() = "0" }
}

class StdIntIntPtrType extends Type {
  StdIntIntPtrType() {
    exists(TypeDeclarationEntry entry |
      /*
       * Just check if there is a header file,
       * because we don't know what header file the declaration might live in
       */

      exists(entry.getFile().(HeaderFile)) and
      entry.getType() = this and
      this.getName().regexpMatch("u?intptr_t")
    )
  }
}

/**
 * Casting a pointer value to integer, excluding literal 0.
 * Includes implicit conversions made during declarations or assignments.
 */
predicate conversionBetweenPointerAndInteger(Cast cast, string message) {
  /* Ensure that `int` has different size than that of pointers */
  exists(IntType intType, PointerType ptrType | intType.getSize() < ptrType.getSize() |
    cast.getExpr().getUnderlyingType() = intType and
    cast.getUnderlyingType() = ptrType and
    if cast.isCompilerGenerated()
    then message = "Integer expression " + cast.getExpr() + " is implicitly cast to a pointer type."
    else message = "Integer expression " + cast.getExpr() + " is cast to a pointer type."
    or
    cast.getExpr().getUnderlyingType() = ptrType and
    cast.getUnderlyingType() = intType and
    if cast.isCompilerGenerated()
    then
      message = "Pointer expression " + cast.getExpr() + " is implicitly cast to an integer type."
    else message = "Pointer expression " + cast.getExpr() + " is cast to an integer type."
  ) and
  /* Compliant exception 1: literal 0 */
  not cast.getExpr() instanceof LiteralZero and
  /* Compliant exception 2: variable's declared type is (u)intptr_t */
  not (
    cast.getType() instanceof StdIntIntPtrType and
    cast.getExpr().getType() instanceof VoidPointerType
    or
    cast.getType() instanceof VoidPointerType and
    cast.getExpr().getType() instanceof StdIntIntPtrType
  )
}

from Element elem, string message
where
  not isExcluded(elem, Types1Package::convertingAPointerToIntegerOrIntegerToPointerQuery()) and
  conversionBetweenPointerAndInteger(elem, message)
select elem, message
