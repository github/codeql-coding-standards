import cpp

class StdNoThrow extends Class {
  StdNoThrow() { hasQualifiedName("std", "nothrow_t") }
}

/**
 * A helper class for identifying and differentiating 'operator delete' functions.
 */
class OperatorDelete extends Operator {
  OperatorDelete() { hasName("operator delete") and getNamespace() instanceof GlobalNamespace }

  predicate isSizeDelete() {
    getNumberOfParameters() = 2 and
    getParameter(1).getType().getUnderlyingType() instanceof Size_t
    or
    getNumberOfParameters() = 3 and
    getParameter(1).getType().getUnderlyingType() instanceof Size_t and
    getParameter(2).getType().getUnderlyingType() instanceof StdNoThrow
  }

  boolean isNoThrowDelete() {
    result = true and
    getNumberOfParameters() = 2 and
    getParameter(1).getType().getUnderlyingType() instanceof StdNoThrow
    or
    result = true and
    getNumberOfParameters() = 3 and
    getParameter(1).getType().getUnderlyingType() instanceof Size_t and
    getParameter(2).getType().getUnderlyingType() instanceof StdNoThrow
  }
}
