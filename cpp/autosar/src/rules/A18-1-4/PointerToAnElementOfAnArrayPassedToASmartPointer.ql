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
import SingleObjectSmartPointerArrayConstructionFlow::PathGraph

class AutosarSmartPointerArraySpecialisation extends AutosarSmartPointer {
  AutosarSmartPointerArraySpecialisation() { this.getOwnedObjectType() instanceof ArrayType }
}

module SingleObjectSmartPointerArrayConstructionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
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

  predicate isSink(DataFlow::Node sink) {
    exists(AutosarSmartPointer sp |
      not sp instanceof AutosarSmartPointerArraySpecialisation and
      (
        sp.getAConstructorCallWithExternalObjectConstruction().getAnArgument() = sink.asExpr()
        or
        sink.asExpr() = sp.getAResetCall().getArgument(0)
      )
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node source, DataFlow::Node sink) {
    exists(AutosarUniquePointer sp, FunctionCall fc |
      fc = sp.getAReleaseCall() and
      source.asExpr() = fc.getQualifier() and
      sink.asExpr() = fc
    )
  }

  predicate isBarrierIn(DataFlow::Node node) {
    // Exclude flow into header files outside the source archive which are summarized by the
    // additional taint steps above.
    exists(AutosarUniquePointer sp |
      sp.getAReleaseCall().getTarget() = node.asExpr().(ThisExpr).getEnclosingFunction()
    |
      not exists(node.getLocation().getFile().getRelativePath())
    )
  }
}

module SingleObjectSmartPointerArrayConstructionFlow =
  TaintTracking::Global<SingleObjectSmartPointerArrayConstructionConfig>;

from
  SingleObjectSmartPointerArrayConstructionFlow::PathNode source,
  SingleObjectSmartPointerArrayConstructionFlow::PathNode sink
where
  not isExcluded(sink.getNode().asExpr(),
    PointersPackage::pointerToAnElementOfAnArrayPassedToASmartPointerQuery()) and
  SingleObjectSmartPointerArrayConstructionFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "A pointer to an element of an array of objects flows to a smart pointer of a single object type."
