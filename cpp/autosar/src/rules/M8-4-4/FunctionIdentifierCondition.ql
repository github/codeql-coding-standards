/**
 * @id cpp/autosar/function-identifier-condition
 * @name M8-4-4: A function identifier shall either be used to call the function or it shall be preceded by &
 * @description A function identifier that doesn't call the function or preceded by & is ambiguous
 *              and can cause confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m8-4-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from FunctionAccess fa
where
  not isExcluded(fa, FunctionsPackage::functionIdentifierConditionQuery()) and
  not fa.getParent() instanceof AddressOfExpr and
  // Function accesses to non-static member functions always use &, but their parent is not an AddressOfExpr.
  not exists(MemberFunction mf |
    mf = fa.getTarget() and
    not mf.isStatic()
  ) and
  // EXCLUSIONS
  // Ignore function accesses that are affected by macros - it's hard to see what's going on.
  not fa.isAffectedByMacro() and
  // Ignore lambdas - Note we do not use `getLambdaFunction` from
  // `LambdaExpression` here because it does not resolve as the target of the
  // `FunctionAccess`.
  not fa.getTarget().getDeclaringType() instanceof Closure and
  // Ignore stream manipulators (e.g. std::endl).
  not exists(FunctionCall fc, Operator op |
    fa = fc.getAnArgument() and
    op = fc.getTarget() and
    (op.hasName("operator<<") or op.hasName("operator>>"))
  )
select fa, "The function identifier $@ is not used to call the function and is not preceded by &.",
  fa.getTarget(), fa.getTarget().getName()
