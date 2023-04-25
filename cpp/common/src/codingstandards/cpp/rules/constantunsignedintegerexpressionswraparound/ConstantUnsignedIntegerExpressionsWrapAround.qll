/**
 * Provides a library which includes a `problems` predicate for reporting unsigned integer
 * wraparound related to constant expressions.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Macro
import codingstandards.cpp.Exclusions
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

abstract class ConstantUnsignedIntegerExpressionsWrapAroundSharedQuery extends Query { }

Query getQuery() { result instanceof ConstantUnsignedIntegerExpressionsWrapAroundSharedQuery }

query predicate problems(BinaryArithmeticOperation bao, string message) {
  not isExcluded(bao, getQuery()) and
  bao.isConstant() and
  bao.getUnderlyingType().(IntegralType).isUnsigned() and
  convertedExprMightOverflow(bao) and
  // Exclude expressions generated from macro invocations of argument-less macros in third party
  // code. This is because these are not under the control of the developer. Macros with arguments
  // are not excluded, so that we can report cases where the argument provided by the developer
  // wraps around (this may also report cases where the macro itself contains a wrapping expression,
  // but we cannot distinguish these cases because we don't know which generated expressions are
  // affected by which arguments).
  //
  // This addresses a false positive in the test cases on UULONG_MAX, which is reported in MUSL
  // because it is defined as (2ULL*LLONG_MAX+1), which is a constant integer expression, and
  // although it doesn't wrap in practice, our range analysis loses precision at the top end of the
  // unsigned long long range so incorrectly assumes it can wrap.
  not exists(LibraryMacro m, MacroInvocation mi |
    mi = m.getAnInvocation() and
    mi.getAnExpandedElement() = bao and
    not exists(mi.getUnexpandedArgument(_))
  ) and
  message = "Use of a constant, unsigned, integer expression that over- or under-flows."
}
