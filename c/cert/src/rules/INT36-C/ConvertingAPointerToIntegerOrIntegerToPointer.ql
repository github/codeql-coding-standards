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

/* 1. Declaring an integer variable to hold a pointer value */
predicate integerVariableWithPointerValue(Variable var) {
  var.getUnderlyingType() instanceof IntType and
  var.getAnAssignedValue().getUnderlyingType() instanceof PointerType
}

/* 2. Assigning an integer variable a pointer a pointer value */
predicate assigningPointerValueToInteger(Assignment assign) {
  assign.getLValue().getUnderlyingType() instanceof IntType and
  assign.getRValue().getUnderlyingType() instanceof PointerType
}

/* 3. Casting a pointer value to integer */
predicate castingPointerToInteger(Cast cast) {
  cast.getExpr().getUnderlyingType() instanceof PointerType and
  cast.getUnderlyingType() instanceof PointerType
}

from Variable x
where
  not isExcluded(x, TypesPackage::convertingAPointerToIntegerOrIntegerToPointerQuery()) and
  x.getType() instanceof PointerType
select x, x.getType().getAPrimaryQlClass()
