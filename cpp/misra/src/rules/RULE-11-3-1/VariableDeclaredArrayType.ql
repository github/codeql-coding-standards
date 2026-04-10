/**
 * @id cpp/misra/variable-declared-array-type
 * @name RULE-11-3-1: Variables of array type should not be declared
 * @description Using array type instead of container types can lead to difficulty manually managing
 *              size and accesses.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-3-1
 *       correctness
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

class FixedSizeCharArray extends Variable {
  FixedSizeCharArray() {
    this.isStatic() and
    this.getUnspecifiedType().stripType() instanceof CharType and
    this.getInitializer().getExpr() instanceof StringLiteral
  }
}

from Variable v
where
  not isExcluded(v, Declarations3Package::variableDeclaredArrayTypeQuery()) and
  exists(ArrayType a | v.getType() = a | not v instanceof FixedSizeCharArray) and
  // Exclude the compiler generated __func__ as it is the only way to access the function name information
  not v.getName() = "__func__"
select v, "Variable " + v.getName() + " has an array type."
