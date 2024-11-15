/**
 * @id c/misra/invalid-literal-for-integer-constant-macro-argument
 * @name RULE-7-5: The argument of an integer constant macro shall be a decimal, hex, or octal literal
 * @description Integer constant macro arguments should be a decimal, hex, or octal literal.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-5
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.IntegerConstantMacro
import codingstandards.cpp.Literals

/**
 * Floating point literals are not allowed. Neither are char or string
 * literals, although those are not `NumericLiteral`s and therefore detected in
 * `InvalidIntegerConstantMacroArgument.ql`.
 */
predicate validLiteralType(PossiblyNegativeLiteral literal) {
  literal.getBaseLiteral() instanceof Cpp14Literal::DecimalLiteral or
  literal.getBaseLiteral() instanceof Cpp14Literal::OctalLiteral or
  literal.getBaseLiteral() instanceof Cpp14Literal::HexLiteral or
  // Ignore cases where the AST/extractor don't give us enough information:
  literal.getBaseLiteral() instanceof Cpp14Literal::UnrecognizedNumericLiteral
}

/**
 * Clang accepts `xINTsize_C(0b01)`, and expands the argument into a decimal
 * literal. Binary literals are not standard c nor are they allowed by rule 7-5.
 * Detect this pattern before macro expansion.
 */
predicate seemsBinaryLiteral(MacroInvocation invoke) {
  invoke.getUnexpandedArgument(0).regexpMatch("-?0[bB][01]+")
}

/**
 * Extractor converts `xINTsize_C('a')` to a decimal literal. Therefore, detect
 * this pattern before macro expansion.
 */
predicate seemsCharLiteral(MacroInvocation invoke) {
  invoke.getUnexpandedArgument(0).regexpMatch("-?'\\\\?.'")
}

string explainIncorrectArgument(MacroInvocation invoke) {
  if seemsBinaryLiteral(invoke)
  then result = "binary literal"
  else
    if seemsCharLiteral(invoke)
    then result = "char literal"
    else
      exists(PossiblyNegativeLiteral literal |
        literal = invoke.getExpr() and
        if literal.getBaseLiteral() instanceof Cpp14Literal::FloatingLiteral
        then result = "floating point literal"
        else result = "invalid literal"
      )
}

from MacroInvocation invoke, PossiblyNegativeLiteral literal
where
  not isExcluded(invoke, Types2Package::invalidLiteralForIntegerConstantMacroArgumentQuery()) and
  invoke.getMacro() instanceof IntegerConstantMacro and
  literal = invoke.getExpr() and
  (
    not validLiteralType(literal) or
    seemsBinaryLiteral(invoke) or
    seemsCharLiteral(invoke)
  )
select literal,
  "Integer constant macro " + invoke.getMacroName() + " used with " +
    explainIncorrectArgument(invoke) +
    " argument, only decimal, octal, or hex integer literal allowed."
