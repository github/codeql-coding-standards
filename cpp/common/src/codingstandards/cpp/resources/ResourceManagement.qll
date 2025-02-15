import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.resources.ResourceLeakAnalysis

module ResourceLeakConfig implements ResourceLeakConfigSig {
  predicate isAllocate(ControlFlowNode allocPoint, DataFlow::Node node) {
    exists(AllocationExpr alloc |
      allocPoint = alloc and
      alloc.requiresDealloc() and
      node.asExpr() = alloc
    )
    or
    exists(FunctionCall f |
      f.getTarget().hasQualifiedName("std", "basic_fstream", "open") and
      allocPoint = f and
      node.asDefiningArgument() = f.getQualifier()
    )
    or
    exists(FunctionCall f |
      f.getTarget().hasQualifiedName("std", "mutex", "lock") and
      allocPoint = f and
      node.asDefiningArgument() = f.getQualifier()
    )
  }

  predicate isFree(ControlFlowNode node, DataFlow::Node resource) {
    exists(DeallocationExpr d, Expr freedExpr |
      freedExpr = d.getFreedExpr() and
      node = d and
      resource.asExpr() = freedExpr
    )
    or
    exists(FunctionCall f |
      f.getTarget().hasQualifiedName("std", "basic_fstream", "close") and
      node = f and
      resource.asExpr() = f.getQualifier()
    )
    or
    exists(FunctionCall f |
      f.getTarget().hasQualifiedName("std", "mutex", "unlock") and
      node = f and
      resource.asExpr() = f.getQualifier()
    )
  }
}
