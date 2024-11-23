/**
 * @id c/misra/variable-length-array-types-used
 * @name RULE-18-8: Variable-length array types shall not be used
 * @description Using a variable length array can lead to unexpected or undefined program behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-8
 *       correctness
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

/**
 * Typedefs may be declared as VLAs, eg, `typedef int vla[x];`. This query finds types that refer to
 * such typedef types, for instance `vla foo;` or adding a dimension via `vla bar[10];`.
 *
 * Consts and other specifiers may be added, but `vla *ptr;` is not a VLA any more, and is excluded.
 */
class VlaTypedefType extends Type {
  VlaDeclStmt vlaDecl;
  ArrayType arrayType;

  VlaTypedefType() {
    // Holds for direct references to the typedef type:
    this = vlaDecl.getType() and
    vlaDecl.getType() instanceof TypedefType and
    arrayType = vlaDecl.getType().stripTopLevelSpecifiers()
    or
    // Handle arrays of VLA typedefs, and carefully handle specified VLA typedef types, as
    // `stripTopLevelSpecifiers` resolves past the VLA typedef type.
    exists(DerivedType dt, VlaTypedefType vlaType |
      (dt instanceof ArrayType or dt instanceof SpecifiedType) and
      this = dt and
      vlaType = dt.getBaseType() and
      vlaDecl = vlaType.getVlaDeclStmt() and
      arrayType = vlaType.getArrayType()
    )
  }

  VlaDeclStmt getVlaDeclStmt() { result = vlaDecl }

  ArrayType getArrayType() { result = arrayType }
}

from Variable v, Expr size, ArrayType arrayType, VlaDeclStmt vlaDecl, string typeStr
where
  not isExcluded(v, Declarations7Package::variableLengthArrayTypesUsedQuery()) and
  size = vlaDecl.getVlaDimensionStmt(0).getDimensionExpr() and
  (
    // Holds is if v is a variable declaration:
    v = vlaDecl.getVariable() and
    arrayType = v.getType().stripTopLevelSpecifiers()
    or
    // Holds is if v is a typedef declaration:
    exists(VlaTypedefType typedef |
      v.getType() = typedef and
      arrayType = typedef.getArrayType() and
      vlaDecl = typedef.getVlaDeclStmt()
    )
  ) and
  typeStr = arrayType.getBaseType().toString()
select v, "Variable length array of element type '" + typeStr + "' with non-constant size $@.",
  size, size.toString()
