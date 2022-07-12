/**
 * @id cpp/cert/do-not-use-pointer-arithmetic-on-polymorphic-objects
 * @name CTR56-CPP: Do not use pointer arithmetic on polymorphic objects
 * @description Pointer arithmetic on polymorphic objects does not account for polymorphic object
 *              sizes and could lead to undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/ctr56-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
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
      c.isPolymorphic()
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
  not isExcluded(e, PointersPackage::doNotUsePointerArithmeticOnPolymorphicObjectsQuery()) and
  any(NonFinalClassToPointerArithmeticExprConfig c).hasFlowPath(source, sink) and
  v.getAnAssignedValue() = source.getNode().asExpr() and
  (
    e.(PointerArithmeticOperation).getAnOperand() = sink.getNode().asExpr()
    or
    e.(ArrayExpr).getArrayBase() = sink.getNode().asExpr()
  ) and
  v.getUnderlyingType().(PointerType).getBaseType() = clz
select e, source, sink, "Pointer arithmetic used on polymorphic object $@.", clz, clz.getName()
