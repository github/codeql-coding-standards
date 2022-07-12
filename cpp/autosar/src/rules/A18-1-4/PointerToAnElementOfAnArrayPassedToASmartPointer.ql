/**
 * @id cpp/autosar/pointer-to-an-element-of-an-array-passed-to-a-smart-pointer
 * @name A18-1-4: A pointer pointing to an element of an array of objects shall not be passed to a smart pointer of a non-array type
 * @description A pointer pointing to an element of an array of objects shall not be passed to a
 *              smart pointer of single object type.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a18-1-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers
import semmle.code.cpp.dataflow.TaintTracking
import DataFlow::PathGraph

class AutosarSmartPointerArraySpecialisation extends AutosarSmartPointer {
  AutosarSmartPointerArraySpecialisation() { this.getOwnedObjectType() instanceof ArrayType }
}

class SingleObjectSmartPointerArrayConstructionConfig extends TaintTracking::Configuration {
  SingleObjectSmartPointerArrayConstructionConfig() {
    this = "SingleObjectSmartPointerArrayConstructionConfig"
  }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof NewArrayExpr or
    source.asExpr() =
      any(FunctionCall fc, MemberFunction mf |
        mf = fc.getTarget() and
        mf.getDeclaringType() instanceof AutosarSmartPointerArraySpecialisation and
        mf instanceof AutosarSmartPointerReleaseMemberFunction
      |
        fc.getParent()
      )
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(AutosarSmartPointer sp |
      not sp instanceof AutosarSmartPointerArraySpecialisation and
      (
        sp.getAConstructorCallWithExternalObjectConstruction().getAnArgument() = sink.asExpr()
        or
        sink.asExpr() =
          any(FunctionCall fc, MemberFunction mf |
            mf = fc.getTarget() and
            mf.getDeclaringType() = sp and
            mf.getName() = "reset"
          |
            fc.getArgument(0)
          )
      )
    )
  }
}

from
  SingleObjectSmartPointerArrayConstructionConfig config, DataFlow::PathNode source,
  DataFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    PointersPackage::pointerToAnElementOfAnArrayPassedToASmartPointerQuery()) and
  config.hasFlowPath(source, sink)
select sink.getNode(), source, sink,
  "A pointer to an element of an array of objects flows to a smart pointer of a single object type."
