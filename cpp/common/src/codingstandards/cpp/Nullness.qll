import cpp
import semmle.code.cpp.dataflow.DataFlow

private class PointerToMember extends Variable {
  PointerToMember() { this.getType() instanceof PointerToMemberType }
}

module NullPointerToPointerMemberExpressionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source.asExpr() instanceof NullValue }

  predicate isSink(DataFlow::Node sink) {
    // The null value can flow to a pointer-to-member expressions that points to a function
    exists(VariableCall call, VariableAccess va | call.getQualifier() = va and va = sink.asExpr() |
      va.getTarget() instanceof PointerToMember
    )
    or
    // or to a pointer-to-member expression that points to a data member.
    exists(VariableAccess va | va.getTarget() instanceof PointerToMember | va = sink.asExpr())
  }
}

module NullPointerToPointerMemberExpressionFlow =
  DataFlow::Global<NullPointerToPointerMemberExpressionConfig>;

module NullValueToAssignmentConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source.asExpr() instanceof NullValue }

  predicate isSink(DataFlow::Node sink) { exists(Assignment a | a.getRValue() = sink.asExpr()) }
}

module NullValueToAssignmentFlow = DataFlow::Global<NullValueToAssignmentConfig>;
