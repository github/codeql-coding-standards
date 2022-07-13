/** Provides a library modeling features provided by the utility header in the standard library. */

import cpp

/** A call to `std::move`. */
class StdMoveCall extends FunctionCall {
  StdMoveCall() {
    getTarget().hasQualifiedName("std", "move") and
    // do not match std::move functions from <algorithm>
    getTarget().getNumberOfParameters() = 1
    or
    // match the KJ implementation
    getTarget().hasQualifiedName("kj", "mv")
  }
}

/** A call to `std::forward`. */
class StdForwardCall extends FunctionCall {
  StdForwardCall() {
    getTarget().hasQualifiedName("std", "forward")
    or
    // match the KJ implementation
    getTarget().hasQualifiedName("kj", "fwd")
  }
}

/*
 * A `ConsumeParameter` is declared as an rvalue reference
 * to non-const non-template type (`X &&`)
 */

class ConsumeReferenceType extends RValueReferenceType {
  ConsumeReferenceType() {
    not getBaseType().isConst() and
    not involvesTemplateParameter()
  }
}

class ConsumeParameter extends Parameter {
  ConsumeParameter() {
    getType() instanceof ConsumeReferenceType and
    not isFromTemplateInstantiation(_)
  }
}

/*
 * A `Forward Parameter` is declared as an rvalue reference
 * to non-const template type (`X &&`)
 * It can also be declared via `auto &&` in a generic lambda
 */

class ForwardingReferenceType extends RValueReferenceType {
  ForwardingReferenceType() {
    not getBaseType().isConst() and
    involvesTemplateParameter()
  }
}

class ForwardParameter extends Parameter {
  ForwardParameter() {
    exists(TemplateFunction tf |
      getFunction().isConstructedFrom(tf) and
      tf.getParameter(getIndex()).getType() instanceof ForwardingReferenceType
    )
  }
}
