/**
 * @id cpp/autosar/auto-specifier-not-used-appropriately-in-variable-definition
 * @name A7-1-5: The auto specifier should only be used when the deducted type is obvious
 * @description The auto specifier shall not be used apart from following cases: (1) to declare that
 *              a variable has the same type as return type of a function call, (2) to declare that
 *              a variable has the same type as initializer of non-fundamental type, (3) to declare
 *              parameters of a generic lambda expression, (4) to declare a function template using
 *              trailing return type syntax.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-1-5
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Variable v
where
  not isExcluded(v,
    DeclarationsPackage::autoSpecifierNotUsedAppropriatelyInVariableDefinitionQuery()) and
  // ignore anything that's not a auto variable.
  v.declaredUsingAutoType() and
  // exclude uninstantiated templates and rely on the instantiated templates, because an uninstantiated template may not contain the information required to determine if the usage is allowed.
  not v.isFromUninstantiatedTemplate(_) and
  not (
    // find ones where
    v.getInitializer().getExpr() instanceof FunctionCall
    or
    v.getInitializer().getExpr() instanceof LambdaExpression
    or
    v.getInitializer().getExpr() instanceof ClassAggregateLiteral
  ) and
  // Exclude compiler generated variables
  not v.isCompilerGenerated()
select v,
  "Use of auto in variable definition is not the result of a function call, lambda expression, or non-fundamental type initializer."
