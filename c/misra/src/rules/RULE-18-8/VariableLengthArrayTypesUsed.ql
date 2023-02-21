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
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

/**
 * A variable length array (VLA)
 * ie an array where the size
 * is not an integer constant expression
 */
class VariableLengthArray extends VariableDeclarationEntry {
  VariableLengthArray() {
    //VLAs will not have: static/extern specifiers (compilation error)
    not this.hasSpecifier("static") and
    not this.hasSpecifier("extern") and
    //VLAs are not allowed to be initialized
    not this.getDeclaration().hasInitializer() and
    exists(ArrayType a |
      //a.hasArraySize() does not catch multidimensional VLAs like a[1][]
      a.toString().matches("%[]%") and
      this.getUnspecifiedType() = a and
      //variable length array is one declared in block or function prototype
      (
        this.getDeclaration().getParentScope() instanceof Function or
        this.getDeclaration().getParentScope() instanceof BlockStmt
      )
    )
  }
}

from VariableLengthArray v
where
  not isExcluded(v, Declarations7Package::variableLengthArrayTypesUsedQuery()) and
  //an exception, argv in : int main(int argc, char *argv[])
  not v.getDeclaration().getParentScope().(Function).hasName("main")
select v, "Variable length array declared."
