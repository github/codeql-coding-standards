/**
 * Provides a library which includes a `problems` predicate for reporting unsigned integer
 * wraparound related to constant expressions.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

abstract class ConstantUnsignedIntegerExpressionsWrapAroundSharedQuery extends Query { }

Query getQuery() { result instanceof ConstantUnsignedIntegerExpressionsWrapAroundSharedQuery }

query predicate problems(BinaryArithmeticOperation bao, string message) {
  not isExcluded(bao, getQuery()) and
  bao.isConstant() and
  bao.getUnderlyingType().(IntegralType).isUnsigned() and
  convertedExprMightOverflow(bao) and
  message = "Use of a constant, unsigned, integer expression that over- or under-flows."
}
