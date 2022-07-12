/**
 * Provides a library which includes a `problems` predicate for reporting uses of
 * `std::throw_with_nested` without an existing nested exception.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.EncapsulatingFunctions
import codingstandards.cpp.exceptions.ExceptionFlow

abstract class RethrowNestedWithoutCaptureSharedQuery extends Query { }

Query getQuery() { result instanceof RethrowNestedWithoutCaptureSharedQuery }

class StdThrowWithNested extends FunctionCall {
  StdThrowWithNested() { getTarget().hasQualifiedName("std", "throw_with_nested") }

  predicate isInsideCatchBlock() { exists(getNearestCatch(getEnclosingStmt())) }
}

Function getFunctionReachableWithoutCatch(StdThrowWithNested throwWithNested) {
  not throwWithNested.isInsideCatchBlock() and
  result = throwWithNested.getEnclosingFunction()
  or
  exists(Call call |
    // The call target is reachable without catch
    call = getCallReachableWithoutCatch(throwWithNested) and
    // The call is not in a catch block
    not exists(getNearestCatch(call.getEnclosingStmt())) and
    // Then the enclosing function is reachable without catch
    result = call.getEnclosingFunction()
  )
}

Call getCallReachableWithoutCatch(StdThrowWithNested throwWithNested) {
  // The call target is reachable without catch
  result.getTarget() = getFunctionReachableWithoutCatch(throwWithNested)
}

newtype TNestedThrowNode =
  TFunction(Function f) { f = getFunctionReachableWithoutCatch(_) } or
  TCall(Call c) { c = getCallReachableWithoutCatch(_) }

class NestedThrowNode extends TNestedThrowNode {
  Function asFunction() { this = TFunction(result) }

  Call asCall() { this = TCall(result) }

  string toString() {
    result = asFunction().toString()
    or
    result = asCall().toString()
  }
}

NestedThrowNode functionNode(Function f) { result.asFunction() = f }

query predicate edges(NestedThrowNode n1, NestedThrowNode n2) {
  exists(Function f, Call c |
    n1 = TCall(c) and
    n2 = TFunction(f) and
    f = c.getEnclosingFunction()
    or
    n1 = TFunction(f) and
    n2 = TCall(c) and
    c.getTarget() = f
  )
}

query predicate problems(
  StdThrowWithNested throwWithNested, NestedThrowNode source, NestedThrowNode sink, string message
) {
  exists(MainLikeFunction main |
    not isExcluded(throwWithNested, getQuery()) and
    main = getFunctionReachableWithoutCatch(throwWithNested) and
    source = functionNode(throwWithNested.getEnclosingFunction()) and
    sink = functionNode(main) and
    message =
      "This throw occurs in a call path from main on which there is not a current exception."
  )
}
