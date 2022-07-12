/**
 * @id cpp/autosar/pointer-arithmetic-used-with-pointers-to-non-final-classes
 * @name A5-0-4: Pointer arithmetic shall not be used with pointers to non-final classes
 * @description Pointer arithmetic shall not be used with pointers to non-final classes because it
 *              is not guaranteed that the pointed-to type of the pointer equals the element type of
 *              the array it points into which can lead to undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a5-0-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Type
import semmle.code.cpp.dataflow.DataFlow
import DataFlow::PathGraph

class ArrayAccessOrPointerArith extends Expr {
  ArrayAccessOrPointerArith() {
    this instanceof ArrayExpr or
    this instanceof PointerArithmeticOperation or
    this instanceof CrementOperation
  }

  Expr getAnOperand() {
    result = this.(ArrayExpr).getArrayBase() or
    result = this.(PointerArithmeticOperation).getAnOperand() or
    result = this.(CrementOperation).getAnOperand()
  }
}

abstract class ClassPointerCreation extends Expr { }

class NewExprPointerCreation extends ClassPointerCreation, NewExpr { }

class AddressOfPointerCreation extends ClassPointerCreation, AddressOfExpr {
  AddressOfPointerCreation() { this.getAnOperand().getUnderlyingType() instanceof Class }
}

class NonFinalClassToPointerArithmeticExprConfig extends DataFlow::Configuration {
  NonFinalClassToPointerArithmeticExprConfig() {
    this = "NonFinalClassToPointerArithmeticExprConfig"
  }

  override predicate isSource(DataFlow::Node source) {
    exists(Class c |
      source.asExpr() instanceof ClassPointerCreation and
      source.asExpr().getUnderlyingType().(PointerType).getBaseType() = c
    |
      not c.isFinal()
    )
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(ArrayAccessOrPointerArith e | e.getAnOperand() = sink.asExpr())
  }
}

from
  ArrayAccessOrPointerArith e, Class clz, Variable v, DataFlow::PathNode source,
  DataFlow::PathNode sink
where
  not isExcluded(e, PointersPackage::pointerArithmeticUsedWithPointersToNonFinalClassesQuery()) and
  any(NonFinalClassToPointerArithmeticExprConfig c).hasFlowPath(source, sink) and
  v.getAnAssignedValue() = source.getNode().asExpr() and
  (
    e.(PointerArithmeticOperation).getAnOperand() = sink.getNode().asExpr()
    or
    e.(ArrayExpr).getArrayBase() = sink.getNode().asExpr()
  ) and
  v.getUnderlyingType().(PointerType).getBaseType() = clz
select e, source, sink, "Pointer arithmetic with pointer to non-final class $@.", clz, clz.getName()
