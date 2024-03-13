import cpp
import semmle.code.cpp.dataflow.DataFlow

/**
 * The `ResourceAcquisitionExpr` abstract class models resource
 * acquisition and release expressions
 */
abstract class ResourceAcquisitionExpr extends Expr {
  abstract Expr getReleaseExpr();
}

// allocation - deallocation
class AllocExpr extends ResourceAcquisitionExpr {
  AllocExpr() { this.(AllocationExpr).requiresDealloc() }

  override Expr getReleaseExpr() {
    exists(DeallocationExpr d | result = d.getFreedExpr()) and
    DataFlow::localFlow(DataFlow::exprNode(this), DataFlow::exprNode(result))
  }
}

// file open-close
class FstreamAcquisitionExpr extends ResourceAcquisitionExpr {
  FstreamAcquisitionExpr() {
    exists(FunctionCall f |
      f.getTarget().hasQualifiedName("std", "basic_fstream", "open") and this = f.getQualifier()
    )
  }

  override Expr getReleaseExpr() {
    exists(FunctionCall f |
      f.getTarget().hasQualifiedName("std", "basic_fstream", "close") and result = f.getQualifier()
    ) and
    exists(DataFlow::Node def |
      def.asDefiningArgument() = this and
      DataFlow::localFlow(def, DataFlow::exprNode(result))
    )
  }
}

// mutex lock unlock
class MutexAcquisitionExpr extends ResourceAcquisitionExpr {
  MutexAcquisitionExpr() {
    exists(FunctionCall f |
      f.getTarget().hasQualifiedName("std", "mutex", "lock") and this = f.getQualifier()
    )
  }

  override Expr getReleaseExpr() {
    exists(FunctionCall f |
      f.getTarget().hasQualifiedName("std", "mutex", "unlock") and result = f.getQualifier()
    ) and
    exists(DataFlow::Node def |
      def.asDefiningArgument() = this and
      DataFlow::localFlow(def, DataFlow::exprNode(result))
    )
  }
}
