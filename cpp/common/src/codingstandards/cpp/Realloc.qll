import cpp
import codingstandards.cpp.CodingStandards

class ReallocCall extends FunctionCall {
  ReallocCall() { getTarget().hasGlobalOrStdName("realloc") }

  Expr getSizeArgument() { result = getArgument(1) }

  predicate sizeIsExactlyZero() {
    upperBound(getSizeArgument().getConversion()) = 0 and
    lowerBound(getSizeArgument().getConversion()) = 0
  }

  predicate sizeMayBeZero() {
    upperBound(getSizeArgument().getConversion()) >= 0 and
    lowerBound(getSizeArgument().getConversion()) <= 0
  }
}
