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

class StdIntIntPtrType extends IntPointerType {
  StdIntIntPtrType() {
    this.getFile().(HeaderFile).getBaseName() = "stdint.h" and
    this.getName().regexpMatch("u?intptr_t")
  }
}

/* 1. Declaring an integer variable to hold a pointer value or the opposite, excluding compliant exceptions */
predicate integerVariableWithPointerValue(Variable var, string message) {
  (
    // Declaring an integer variable to hold a pointer value
    var.getUnderlyingType() instanceof IntType and
    var.getAnAssignedValue().getUnderlyingType() instanceof PointerType and
    message =
      "Integer variable " + var + " is declared as an expression " + var.getAnAssignedValue() +
        ", which is of a pointer type."
    or
    // Declaring an pointer variable to hold a integer value
    var.getUnderlyingType() instanceof PointerType and
    var.getAnAssignedValue().getUnderlyingType() instanceof IntType and
    message =
      "Pointer variable " + var + " is declared as an expression " + var.getAnAssignedValue() +
        ", which is of integer type."
  ) and
  /* Compliant exception 1: literal 0 */
  not var.getAnAssignedValue() instanceof LiteralZero and
  /* Compliant exception 2: variable's declared type is (u)intptr_t */
  not var.getUnderlyingType() instanceof StdIntIntPtrType
}

/* 2. Assigning an integer variable a pointer a pointer value, excluding literal 0 */
predicate assigningPointerValueToInteger(Assignment assign, string message) {
  (
    assign.getLValue().getUnderlyingType() instanceof IntType and
    assign.getRValue().getUnderlyingType() instanceof PointerType and
    message =
      "Integer variable " + assign.getLValue() + " is assigned an expression " + assign.getRValue() +
        ", which is of a pointer type."
    or
    assign.getLValue().getUnderlyingType() instanceof PointerType and
    assign.getRValue().getUnderlyingType() instanceof IntType and
    message =
      "Pointer variable " + assign.getLValue() + " is assigned an expression " + assign.getRValue() +
        ", which is of integer type."
  ) and
  /* Compliant exception 1: literal 0 */
  not assign.getRValue() instanceof LiteralZero and
  /* Compliant exception 2: variable's declared type is (u)intptr_t */
  not assign.getLValue().getUnderlyingType() instanceof StdIntIntPtrType
}

/* 3. Casting a pointer value to integer, excluding literal 0 */
predicate castingPointerToInteger(Cast cast, string message) {
  not cast.isCompilerGenerated() and
  (
    cast.getExpr().getUnderlyingType() instanceof IntType and
    cast.getUnderlyingType() instanceof PointerType and
    message = "Integer expression " + cast.getExpr() + " is cast to a pointer type."
    or
    cast.getExpr().getUnderlyingType() instanceof PointerType and
    cast.getUnderlyingType() instanceof IntType and
    message = "Pointer expression " + cast.getExpr() + " is cast to integer type."
  ) and
  /* Compliant exception 1: literal 0 */
  not cast.getExpr() instanceof LiteralZero and
  /* Compliant exception 2: variable's declared type is (u)intptr_t */
  not cast.getUnderlyingType() instanceof StdIntIntPtrType
}

from Element elem, string message
where
  not isExcluded(elem, TypesPackage::convertingAPointerToIntegerOrIntegerToPointerQuery()) and
  (
    integerVariableWithPointerValue(elem, message)
    or
    assigningPointerValueToInteger(elem, message)
    or
    castingPointerToInteger(elem, message)
  ) and
  /* Ensure that `int` has different size than that of pointers */
  forall(IntType intType, PointerType ptrType | intType.getSize() != ptrType.getSize())
select elem, message
