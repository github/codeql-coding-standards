/**
 * @id cpp/autosar/underlying-bit-representations-of-floating-point-values-used
 * @name M3-9-3: The underlying bit representations of floating-point values shall not be used
 * @description The underlying bit representations of floating-point values shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m3-9-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow

predicate pointeeIsModified(PointerDereferenceExpr e, Expr m) {
  exists(Assignment a | a.getLValue() = e and m = a)
  or
  exists(CrementOperation c | c.getOperand() = e and c = m)
  or
  exists(FunctionCall c | c.getQualifier() = e and c.getTarget().hasName("operator=") and c = m)
} //sink

from Cast c, Expr m, DataFlow::Node sink
where
  not isExcluded(m,
    RepresentationPackage::underlyingBitRepresentationsOfFloatingPointValuesUsedQuery()) and
  //find a flow from the cast to a pointer dereference expression that is an operand of a modifying operation
  (
    c.getExpr().getUnspecifiedType().(PointerType).getBaseType() instanceof FloatType and
    c.getType().getUnspecifiedType().(PointerType).getBaseType() instanceof IntegralType
  ) and
  exists(DataFlow::Node source, PointerDereferenceExpr deref |
    DataFlow::localFlow(source, sink) and
    source.asExpr() = c.getExpr() and
    pointeeIsModified(deref, m) and
    sink.asExpr() = deref.getOperand().getAChild*()
  )
select m, "Modification of bit-representation of float originated at $@", c, "cast"
