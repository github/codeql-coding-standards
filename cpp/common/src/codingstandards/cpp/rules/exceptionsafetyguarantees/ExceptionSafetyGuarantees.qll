/**
 * Provides a library which includes a `problems` predicate for reporting objects
 * that might be in an undetermined state upon uncaught exception
 */

import cpp
import semmle.code.cpp.controlflow.SubBasicBlocks
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.ExceptionSafety
import codingstandards.cpp.exceptions.ExceptionFlow

abstract class ExceptionSafetyGuaranteesSharedQuery extends Query { }

Query getQuery() { result instanceof ExceptionSafetyGuaranteesSharedQuery }

/**
 * Ensures that `UncaughtFieldAllocation` and `ThisFieldAssignExpr` appear at the start of a `SubBasicBlock`.
 */
class SafetyGuaranteeSubBasicBlock extends SubBasicBlockCutNode {
  SafetyGuaranteeSubBasicBlock() {
    this instanceof UncaughtFieldAllocation or this instanceof ThisFieldAssignExpr
  }
}

/**
 * Models calls to new or new[] that could throw an uncaught exception
 */
class UncaughtFieldAllocation extends NewOrNewArrayExpr {
  UncaughtFieldAllocation() {
    // not in a try-catch block
    not exists(TryStmt t | t = getNearestTry(this.getEnclosingStmt()))
  }
}

/**
 * Models access to fields of `this`
 */
class ThisFieldAccess extends FieldAccess {
  ThisFieldAccess() {
    this instanceof ImplicitThisFieldAccess
    or
    this.(PointerFieldAccess).getQualifier() instanceof ThisExpr
  }
}

/**
 * Models assignments to fields of `this`
 */
class ThisFieldAssignExpr extends Expr {
  ThisFieldAssignExpr() {
    // new object assigned to a field
    exists(AssignExpr e | e.getLValue() instanceof ThisFieldAccess and this = e.getRValue())
    or
    // new object initializing a field
    exists(ConstructorFieldInit i | i.getExpr() = this)
  }
}

/**
 * An exception occurs in an undetermined object state
 */
query predicate problems(UncaughtFieldAllocation te, string message) {
  not isExcluded(te, getQuery()) and
  exists(SubBasicBlock sbb |
    sbb.getANode() = te and
    sbb.getASuccessor*() instanceof ThisFieldAssignExpr and
    sbb.getAPredecessor+() instanceof ThisFieldAssignExpr
  ) and
  message = "Throwing an exception here will leave the object in an undetermined state."
}
