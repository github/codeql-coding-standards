/**
 * @id cpp/misra/pointer-arithmetic-forms-an-invalid-pointer
 * @name RULE-8-7-1: Pointer arithmetic shall not form an invalid pointer.
 * @description Pointers obtained as result of performing arithmetic should point to an initialized
 *              object, or an element right next to the last element of an array.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-7-1
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.security.BufferAccess

class ArrayDeclaration extends VariableDeclarationEntry {
  int length;

  ArrayDeclaration() { this.getType().getUnderlyingType().(ArrayType).getArraySize() = length }

  /**
   * Gets the declared length of this array.
   */
  int getLength() { result = length }
}

newtype TArrayAllocation =
  TStackAllocation(ArrayDeclaration arrayDecl) or
  TDynamicAllocation(AllocationFunction alloc)

class ArrayAllocation extends TArrayAllocation {
  ArrayDeclaration asStackAllocation() { this = TStackAllocation(result) }

  AllocationFunction asDynamicAllocation() { this = TDynamicAllocation(result) }

  string toString() {
    result = this.asStackAllocation().toString() or
    result = this.asDynamicAllocation().toString()
  }

  int getLength() {
    result = this.asStackAllocation().getLength() or
    none() // TODO: this.asDynamicAllocation()
  }
}

module TrackArrayConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    /* 1. Declaring / Initializing an array-type variable */
    exists(ArrayDeclaration arrayDecl |
      node.asExpr() = arrayDecl.getVariable().getInitializer().getExpr()
    )
    or
    /* 2. Allocating dynamic memory as an array */
    none() // TODO
  }

  predicate isSink(DataFlow::Node node) {
    /* 1. Pointer arithmetic */
    exists(PointerArithmeticOperation pointerArithmetic |
      node.asIndirectExpr() = pointerArithmetic.getAnOperand()
    )
    or
    /* 2. Array access */
    node.asExpr() instanceof ArrayExprBA
  }
}

module TrackArray = DataFlow::Global<TrackArrayConfig>;

private predicate arrayDeclarationAndAccess(
  DataFlow::Node arrayDeclaration, DataFlow::Node arrayAccess
) {
  TrackArray::flow(arrayDeclaration, arrayAccess)
}

private predicate arrayIndexExceedsOutOfBounds(
  DataFlow::Node arrayDeclaration, DataFlow::Node arrayAccess
) {
  arrayDeclarationAndAccess(arrayDeclaration, arrayAccess) and
  // exists(int declaredLength |
  //   declaredLength = arrayDeclaration
  // )
  any() // TODO
}

from Expr expr
where
  not isExcluded(expr, Memory1Package::pointerArithmeticFormsAnInvalidPointerQuery()) and
  none() // TODO
select "TODO", "TODO"
