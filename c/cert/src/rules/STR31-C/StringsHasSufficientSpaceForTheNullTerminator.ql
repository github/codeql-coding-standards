/**
 * @id c/cert/strings-has-sufficient-space-for-the-null-terminator
 * @name STR31-C: Guarantee that storage for strings has sufficient space for character data and the null terminator
 * @description Many library functions in the C standard library assume C strings are null
 *              terminated and failing to null terminate strings may lead to unpredictable program
 *              behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/str31-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.PossiblyUnsafeStringOperation

/**
 * Models a class of function calls that are unsafe.
 */
class PossiblyUnsafeStringFunctionCall extends FunctionCall {
  PossiblyUnsafeStringFunctionCall() { getTarget().getName() = ["gets", "getchar"] }
}

/**
 * Models a family of expression that produce results that are
 * potentially unbounded.
 */
class PossiblyUnboundedExpr extends Expr {
  PossiblyUnboundedExpr() {
    // argv
    exists(Function f |
      f.hasName("main") and
      this = f.getParameter(1).getAnAccess()
    )
    or
    // getenv
    exists(FunctionCall fc |
      fc.getTarget().hasName("getenv") and
      this = fc
    )
  }
}

from Expr e
where
  not isExcluded(e, Strings1Package::stringsHasSufficientSpaceForTheNullTerminatorQuery()) and
  e instanceof PossiblyUnsafeStringOperation
  or
  e instanceof PossiblyUnsafeStringFunctionCall
  or
  exists(CharArrayInitializedWithStringLiteral cl |
    cl.getContainerLength() <= cl.getStringLiteralLength() and
    TaintTracking::localTaint(DataFlow::exprNode(cl), DataFlow::exprNode(e))
  )
  or
  e instanceof PossiblyUnboundedExpr and
  exists(FunctionCall fc |
    fc.getTarget() instanceof StandardCStringFunction and
    TaintTracking::localTaint(DataFlow::exprNode(e), DataFlow::exprNode(fc.getAnArgument()))
  )
select e,
  "Expression produces or consumes a string that may not have sufficient space for a null-terminator."
