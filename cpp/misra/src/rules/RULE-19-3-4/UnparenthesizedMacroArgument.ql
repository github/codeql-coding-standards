/**
 * @id cpp/misra/unparenthesized-macro-argument
 * @name RULE-19-3-4: Parentheses shall be used to ensure macro arguments are expanded appropriately
 * @description Expanded macro arguments shall be enclosed in parentheses to ensure the resulting
 *              expressions have the expected precedence and order of operations.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-19-3-4
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Macro
import codingstandards.cpp.MatchingParenthesis
import codeql.util.Boolean

/**
 * This regex is used to find macro arguments that appear to have critical operators in them, before
 * we do the expensive process of parsing them to look for parenthesis.
 */
pragma[noinline]
string criticalOperatorRegex() {
  result =
    ".*(" +
      concat(string op |
        op in [
            "\\*=?", "/=?", "%=?", "\\+=?", "-=?", "<<?=?", ">>?=?", "==?", "!=", "&&?=?", "\\^/?",
            "\\|\\|?=?", "\\?"
          ]
      |
        op, "|"
      ) + ").*"
}

/**
 * Whether a string appears to contain a critical operator.
 */
bindingset[input]
predicate hasCriticalOperator(string input) { input.regexpMatch(criticalOperatorRegex()) }

/**
 * A critical operator is an operator with "level" between 13 and 2, according to the MISRA C++
 * standard. This includes from the "multiplicative" level (13) to the "conditional" level (2).
 */
class CriticalOperatorExpr extends Expr {
  string operator;

  CriticalOperatorExpr() {
    operator = this.(BinaryOperation).getOperator()
    or
    this instanceof ConditionalExpr and operator = "?"
    or
    operator = this.(Assignment).getOperator()
  }

  string getOperator() { result = operator }
}

/**
 * An invocation of a macro that has a parameter that is not precedence-protected with parentheses,
 * and that produces a critical operator expression.
 *
 * This class is used in two passes. Firstly, with `hasRiskyParameter`, to find the macro paramaters
 * that should be parsed for parenthesis. Secondly, with `hasNonCompliantParameter`, to parse the
 * risky parameters and attempt to match the produced AST to an unparenthesized occurence of that
 * operator in the argument text.
 *
 * For a given macro invocation to be considered risky, it must
 * - The macro must have a parameter that is not precedence-protected with parentheses.
 * - The macro must produce a critical operator expression.
 * - The macro must produce only expressions, statements, or variable declarations with initializers.
 *
 * For a risky macro to be non-compliant, it must hold for some values of the predicate
 * `hasNonCompliantParameter`.
 */
class RiskyMacroInvocation extends MacroInvocation {
  FunctionLikeMacro macro;
  string riskyParamName;
  int riskyParamIdx;

  RiskyMacroInvocation() {
    macro = getMacro() and
    // The parameter is not precedence-protected with parentheses in the macro body.
    macro.parameterPrecedenceUnprotected(riskyParamIdx) and
    riskyParamName = macro.getParameter(riskyParamIdx) and
    // This macro invocation produces a critical operator expression.
    getAGeneratedElement() instanceof CriticalOperatorExpr and
    // It seems to generate an expression, statement, or variable declaration with initializer.
    forex(Element e | e = getAGeneratedElement() |
      e instanceof Expr
      or
      e instanceof Stmt
      or
      e.(Variable).getInitializer().getExpr() = getAGeneratedElement()
      or
      e.(VariableDeclarationEntry).getDeclaration().getInitializer().getExpr() =
        getAGeneratedElement()
    )
  }

  /**
   * A stage 1 pass used to find macro parameters that are not precedence-protected, and have a
   * critical operator in them, and therefore need to be parsed to check for parenthesis at the
   * macro call-site, which is expensive.
   */
  predicate hasRiskyParameter(string name, int index, string value) {
    name = riskyParamName and
    index = riskyParamIdx and
    value = getExpandedArgument(riskyParamIdx) and
    hasCriticalOperator(value)
  }

  /**
   * A stage 2 pass that occurs after risky parameters have been parsed, to check for parenthesis at the macro
   * call-site.
   *
   * For a given macro argument to be flagged, it must:
   * - be risky as determined by the characteristic predicate (produce a critical operator and only
   *   expressions, statements, etc).
   * - be flagged by stage 1 as a risky parameter (i.e. it must have a critical operator in it and
   *   correspond to a macro parameter that is not precedence-protected with parentheses)
   * - there must be a top-level text node that contains the operator in the argument string
   * - the operator cannot be the first character in the string (i.e. it should not look like a
   *   unary - or +)
   * - the operator cannot exist inside a generated string literal
   * - the operator existence of the operator should not be as a substring of "->", "++", or "--"
   *   operators.
   *
   * The results of this predicate should be flagged by the query.
   */
  predicate hasNonCompliantParameter(string name, int index, string value, string operator) {
    hasRiskyParameter(name, index, value) and
    exists(
      ParsedRoot parsedRoot, ParsedText topLevelText, string text, CriticalOperatorExpr opExpr,
      int opIndex
    |
      parsedRoot.getInputString() = value and
      (topLevelText.getParent() = parsedRoot or topLevelText = parsedRoot) and
      text = topLevelText.getText().trim() and
      opExpr = getAGeneratedElement() and
      operator = opExpr.getOperator() and
      opIndex = text.indexOf(operator) and
      // Ignore "->", "++", and "--" operators.
      not [text.substring(opIndex - 1, opIndex + 1), text.substring(opIndex, opIndex + 2)] =
        ["--", "++", "->"] and
      // Ignore operators inside string literals.
      not exists(Literal l |
        l = getAGeneratedElement() and
        exists(l.getValue().indexOf(operator))
      ) and
      // A leading operator is probably unary and not a problem.
      (opIndex > 0 or topLevelText.getChildIdx() > 0)
    )
  }
}

/**
 * A string class that is used to determine what macro arguments will be parsed.
 *
 * This should be a reasonably small set of strings, as parsing is expensive.
 */
class RiskyMacroArgString extends string {
  RiskyMacroArgString() { any(RiskyMacroInvocation mi).hasRiskyParameter(_, _, this) }
}

// Import `ParsedRoot` etc for the parsed macro arguments.
import MatchingParenthesis<RiskyMacroArgString>

from
  RiskyMacroInvocation mi, FunctionLikeMacro m, string paramName, string criticalOperator,
  int paramIndex, string argumentString
where
  not isExcluded([m.(Element), mi.(Element)],
    Preprocessor2Package::unparenthesizedMacroArgumentQuery()) and
  mi.getMacro() = m and
  mi.hasNonCompliantParameter(paramName, paramIndex, argumentString, criticalOperator)
select mi,
  "Macro argument " + paramIndex + " (with expanded value '" + argumentString + "') contains a" +
    " critical operator '" + criticalOperator +
    "' that is not parenthesized, but macro $@ argument '" + paramName +
    "' is not precedence-protected with parenthesis.", m, m.getName()
