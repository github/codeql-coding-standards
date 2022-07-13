import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.DataFlow2

private class PointerToMember extends Variable {
  PointerToMember() { this.getType() instanceof PointerToMemberType }
}

class NullPointerToPointerMemberExpressionConfig extends DataFlow::Configuration {
  NullPointerToPointerMemberExpressionConfig() {
    this = "NullPointerToPointerMemberExpressionConfig"
  }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof NullValue }

  override predicate isSink(DataFlow::Node sink) {
    // The null value can flow to a pointer-to-member expressions that points to a function
    exists(VariableCall call, VariableAccess va | call.getQualifier() = va and va = sink.asExpr() |
      va.getTarget() instanceof PointerToMember
    )
    or
    // or to a pointer-to-member expression that points to a data member.
    exists(VariableAccess va | va.getTarget() instanceof PointerToMember | va = sink.asExpr())
  }
}

class NullValueToAssignmentConfig extends DataFlow2::Configuration {
  NullValueToAssignmentConfig() { this = "NullValueToAssignmentConfig" }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof NullValue }

  override predicate isSink(DataFlow::Node sink) {
    exists(Assignment a | a.getRValue() = sink.asExpr())
  }
}
