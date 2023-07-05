/**
 * @id c/cert/non-null-terminated-to-function-that-expects-a-string
 * @name STR32-C: Do not pass a non-null-terminated character sequence to a library function that expects a string
 * @description Passing a string that is not null-terminated can lead to unpredictable program
 *              behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/str32-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Naming
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.PossiblyUnsafeStringOperation

/**
 * Models a function that is part of the standard library that expects a
 * null-terminated string as an argument. Note that most standard library
 * functions expect this; as a simplifying assumption we assume that a flow
 * into these functions implies such a usage.
 */
class ExpectsNullTerminatedStringAsArgumentFunctionCall extends FunctionCall {
  Expr e;

  ExpectsNullTerminatedStringAsArgumentFunctionCall() {
    Naming::Cpp14::hasStandardLibraryFunctionName(getTarget().getName()) and
    exists(Type t |
      e = getAnArgument() and
      t = getTarget().getAParameter().getType().(DerivedType).getBaseType*() and
      (t instanceof CharType or t instanceof Wchar_t)
    )
  }

  /**
   * This predicate will produce a result equal to any argument of a function
   * that expects null-terminated strings.
   */
  Expr getAnExpectingExpr() { result = e }
}

from ExpectsNullTerminatedStringAsArgumentFunctionCall fc, Expr e, Expr target
where
  target = fc.getAnExpectingExpr() and
  not isExcluded(fc, Strings1Package::nonNullTerminatedToFunctionThatExpectsAStringQuery()) and
  (
    exists(PossiblyUnsafeStringOperation op |
      // don't report violations of the same function call.
      not op = fc and
      e = op and
      TaintTracking::localTaint(DataFlow::exprNode(op.getAnArgument()), DataFlow::exprNode(target))
    )
    or
    exists(CharArrayInitializedWithStringLiteral op |
      e = op and
      op.getContainerLength() <= op.getStringLiteralLength() and
      TaintTracking::localTaint(DataFlow::exprNode(op), DataFlow::exprNode(target))
    )
  ) and
  // don't report cases flowing to this node where there is a flow from a
  // literal assignment of a null terminator
  not exists(AssignExpr aexp |
    aexp.getLValue() instanceof ArrayExpr and
    aexp.getRValue() instanceof Zero and
    TaintTracking::localTaint(DataFlow::exprNode(aexp.getRValue()), DataFlow::exprNode(target)) and
    // this must be AFTER the operation causing the non-null termination to be valid.
    aexp.getAPredecessor*() = e
  )
select fc, "String modified by $@ is passed to function expecting a null-terminated string.", e,
  "this expression"
