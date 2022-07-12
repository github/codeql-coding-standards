import cpp
import semmle.code.cpp.dataflow.DataFlow

newtype TFieldQualifier =
  ExplicitQualifier(VariableAccess v) or
  ImplicitQualifier(ThisExpr te)

FieldQualifier asFieldQualifier(Expr e) { result.asExpr() = e }

class FieldQualifier extends TFieldQualifier {
  string toString() {
    exists(VariableAccess v | this = ExplicitQualifier(v) and result = v.toString())
    or
    exists(ThisExpr te | this = ImplicitQualifier(te) and result = te.toString())
  }

  Location getLocation() {
    exists(VariableAccess v | this = ExplicitQualifier(v) and result = v.getLocation())
    or
    exists(ThisExpr te | this = ImplicitQualifier(te) and result = te.getLocation())
  }

  Expr asExpr() {
    exists(VariableAccess v | this = ExplicitQualifier(v) and result = v)
    or
    exists(ThisExpr te | this = ImplicitQualifier(te) and result = te)
  }

  Expr getAnAccess() {
    exists(VariableAccess v | this = ExplicitQualifier(v) and result = v)
    or
    exists(ThisExpr te | this = ImplicitQualifier(te) and result = te)
  }

  Variable getTarget() {
    exists(VariableAccess v | this = ExplicitQualifier(v) and result = v.getTarget())
  }

  Type getType() {
    exists(VariableAccess v | this = ExplicitQualifier(v) and result = v.getType())
    or
    exists(ThisExpr te | this = ImplicitQualifier(te) and result = te.getType())
  }

  FieldQualifier getQualifier() {
    exists(VariableAccess v |
      this = ExplicitQualifier(v) and
      (
        result = ExplicitQualifier(v.getQualifier())
        or
        result = ImplicitQualifier(v.getQualifier())
      )
    )
  }
}

predicate hasStructuralEquivalentAccessPath(
  FieldQualifier lhsRoot, FieldQualifier lhs, FieldQualifier rhsRoot, FieldQualifier rhs
) {
  // Base case: we have reached the roots of both access paths.
  lhsRoot = lhs and
  rhsRoot = rhs
  or
  // Both field accesses have a qualifier that needs have a matching access path.
  // The qualifier can have a different name (could be a parameter to a called function),
  // but the fields must be equal (by name and type).
  // void setBar(T foo) { this.foo.bar = foo.bar }; setBar(foo);
  hasStructuralEquivalentAccessPath(lhsRoot, lhs.getQualifier(), rhsRoot, rhs.getQualifier()) and
  lhs.getTarget().getName() = rhs.getTarget().getName() and
  lhs.getType() = rhs.getType()
  or
  // If one the field accesses does not have a qualifier and is a normal variable access we
  // assume the rhs has a different name and we try to match the lhs with the argument matching the parameter.
  // void setBar(int bar) {this.foo.bar = bar}; set(foo.bar);
  // Note that we assume that only the rhs can have a partial access path and that the lhs is always
  // a full access path of the form this->foo.bar.baz.
  exists(FunctionCall call, Expr arg, Parameter p, int i |
    call.getTarget() = rhs.asExpr().getEnclosingFunction() and
    call.getArgument(i) = arg and
    p = call.getTarget().getParameter(i) and
    DataFlow::localFlow(DataFlow::parameterNode(p), DataFlow::exprNode(rhs.asExpr())) and
    exists(FieldQualifier argQualifier |
      argQualifier = asFieldQualifier(arg)
      or
      // p is instanceof `PointerType` it could be that the argument is an `AddressOfExpr` and we continue
      // the structural comparison on the address taken variable access.
      argQualifier = asFieldQualifier(arg.(AddressOfExpr).getOperand())
    |
      hasStructuralEquivalentAccessPath(lhsRoot, lhs, rhsRoot, argQualifier)
    )
  )
}
