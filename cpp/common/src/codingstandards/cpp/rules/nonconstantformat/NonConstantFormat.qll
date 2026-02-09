import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.commons.Printf

abstract class NonConstantFormatSharedQuery extends Query { }

Query getQuery() { result instanceof NonConstantFormatSharedQuery }

// For the following `...gettext` functions, we assume that
// all translations preserve the type and order of `%` specifiers
// (and hence are safe to use as format strings).  This
// assumption is hard-coded into the query.
predicate whitelistFunction(Function f, int arg) {
  // basic variations of gettext
  f.getName() = "_" and arg = 0
  or
  f.getName() = "gettext" and arg = 0
  or
  f.getName() = "dgettext" and arg = 1
  or
  f.getName() = "dcgettext" and arg = 1
  or
  // plural variations of gettext that take one format string for singular and another for plural form
  f.getName() = "ngettext" and
  (arg = 0 or arg = 1)
  or
  f.getName() = "dngettext" and
  (arg = 1 or arg = 2)
  or
  f.getName() = "dcngettext" and
  (arg = 1 or arg = 2)
}

// we assume that ALL uses of the `_` macro
// return constant string literals
predicate underscoreMacro(Expr e) {
  exists(MacroInvocation mi |
    mi.getMacroName() = "_" and
    mi.getExpr() = e
  )
}

/**
 * Holds if `t` cannot hold a character array, directly or indirectly.
 */
predicate cannotContainString(Type t) {
  t.getUnspecifiedType() instanceof BuiltInType
  or
  t.getUnspecifiedType() instanceof IntegralOrEnumType
}

predicate isNonConst(DataFlow::Node node) {
  exists(Expr e | e = node.asExpr() |
    exists(FunctionCall fc | fc = e.(FunctionCall) |
      not (
        whitelistFunction(fc.getTarget(), _) or
        fc.getTarget().hasDefinition()
      )
    )
    or
    exists(Parameter p | p = e.(VariableAccess).getTarget().(Parameter) |
      p.getFunction().getName() = "main" and p.getType() instanceof PointerType
    )
    or
    e instanceof CrementOperation
    or
    e instanceof AddressOfExpr
    or
    e instanceof ReferenceToExpr
    or
    e instanceof AssignPointerAddExpr
    or
    e instanceof AssignPointerSubExpr
    or
    e instanceof PointerArithmeticOperation
    or
    e instanceof FieldAccess
    or
    e instanceof PointerDereferenceExpr
    or
    e instanceof AddressOfExpr
    or
    e instanceof ExprCall
    or
    e instanceof NewArrayExpr
    or
    e instanceof AssignExpr
    or
    exists(Variable v | v = e.(VariableAccess).getTarget() |
      v.getType().(ArrayType).getBaseType() instanceof CharType and
      exists(AssignExpr ae |
        ae.getLValue().(ArrayExpr).getArrayBase().(VariableAccess).getTarget() = v
      )
    )
  )
  or
  node instanceof DataFlow::DefinitionByReferenceNode
}

pragma[noinline]
predicate isSanitizerNode(DataFlow::Node node) {
  underscoreMacro(node.asExpr())
  or
  cannotContainString(node.getType())
}

module NonConstConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    isNonConst(source) and
    not cannotContainString(source.getType())
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FormattingFunctionCall fc | sink.asExpr() = fc.getArgument(fc.getFormatParameterIndex()))
  }

  predicate isBarrier(DataFlow::Node node) { isSanitizerNode(node) }
}

module NonConstFlow = TaintTracking::Global<NonConstConfig>;

query predicate problems(
  Expr formatString, string message, FormattingFunctionCall call, string formatStringDescription
) {
  not isExcluded(formatString, getQuery()) and
  call.getArgument(call.getFormatParameterIndex()) = formatString and
  exists(DataFlow::Node source, DataFlow::Node sink |
    NonConstFlow::flow(source, sink) and
    sink.asExpr() = formatString
  ) and
  message =
    "The format string argument to `$@` should be constant to prevent security issues and other potential errors." and
  formatStringDescription = call.getTarget().getName()
}
