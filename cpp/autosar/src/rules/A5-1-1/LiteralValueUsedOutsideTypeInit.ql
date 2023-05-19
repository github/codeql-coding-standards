/**
 * @id cpp/autosar/literal-value-used-outside-type-init
 * @name A5-1-1: Literal values shall not be used apart from type initialization
 * @description Literal values shall not be used apart from type initialization, otherwise symbolic
 *              names shall be used instead.
 * @kind problem
 * @precision low
 * @problem.severity recommendation
 * @tags external/autosar/id/a5-1-1
 *       readability
 *       external/autosar/audit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.LoggingOperation
import codingstandards.cpp.Literals

from Literal l
where
  not isExcluded(l, LiteralsPackage::literalValueUsedOutsideTypeInitQuery()) and
  not exists(Initializer i | i.getExpr() = l) and
  not exists(ConstructorCall cc | cc.getAnArgument() = l) and
  not exists(ConstructorFieldInit cf | cf.getExpr() = l) and
  not l = any(LoggingOperation logOp).getALoggedExpr().getAChild*() and
  // Exclude arguments to wrapper functions (depth 1)
  not exists(FunctionCall fc, LoggerOrStreamWrapperFunction w |
    fc.getAnArgument() = l and w.getACallToThisFunction() = fc
  ) and
  // Exclude Macros with names like *LOG
  not exists(MacroInvocation m | m.getMacroName().matches("%LOG") and m.getAnAffectedElement() = l) and
  // Exclude literal 0
  not l.getValue() = "0" and
  // Exclude character literals
  not l instanceof CharLiteral and
  // Exclude `nullptr`
  not l.getType() instanceof NullPointerType and
  // Exclude boolean `true` and `false`
  not l.getType() instanceof BoolType and
  // Exclude empty string
  not l.getValue() = "" and
  // Template functions use literals to represent calls which are unknown
  not l.getEnclosingFunction() instanceof TemplateFunction and
  // Literals with parents of `ExprCall` are synthetic literals
  not l.getParent() instanceof ExprCall and
  // Macro expansions are morally excluded
  not l = any(MacroInvocation mi).getAnExpandedElement() and
  // Aggregate literal
  not l = any(ArrayOrVectorAggregateLiteral aal).getElementExpr(_).getAChild*() and
  // Ignore x - 1 expressions
  not exists(SubExpr se | se.getRightOperand() = l and l.getValue() = "1")
select l,
  "Literal value " + getTruncatedLiteralText(l) + " used outside of type initialization " +
    l.getAPrimaryQlClass()
