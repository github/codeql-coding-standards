/**
 * @id cpp/autosar/variable-missing-constexpr
 * @name A7-1-2: The constexpr specifier shall be used for variables that can be determined at compile time
 * @description Using 'constexpr' makes it clear that a variable is intended to be compile time
 *              constant.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-1-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.TrivialType
import codingstandards.cpp.SideEffect

predicate isZeroInitializable(Variable v) {
  not exists(v.getInitializer().getExpr()) and
  (
    v instanceof StaticStorageDurationVariable
    or
    isTypeZeroInitializable(v.getType())
  )
}

predicate isTypeZeroInitializable(Type t) {
  t.getUnspecifiedType() instanceof Class
  or
  t.getUnderlyingType() instanceof ArrayType
}

from Variable v
where
  not isExcluded(v, ConstPackage::variableMissingConstexprQuery()) and
  v.hasDefinition() and
  not v.isConstexpr() and
  not v instanceof Parameter and
  not v.isAffectedByMacro() and
  isLiteralType(v.getType()) and
  // Unfortunately, `isConstant` is not sufficient here because it doesn't include calls to
  // constexpr constructors, and does not take into account zero initialization
  (
    v.getInitializer().getExpr().isConstant()
    or
    v.getInitializer().getExpr().(Call).getTarget().isConstexpr()
    or
    isZeroInitializable(v)
    or
    // Value initialized
    v.getInitializer().getExpr().(AggregateLiteral).getNumChild() = 0
  ) and
  // Not modified directly
  not exists(VariableEffect e | e.getTarget() = v) and
  // No address taken in a non-const way
  not v.getAnAccess().isAddressOfAccessNonConst() and
  // Not assigned by a user in a constructor
  not exists(ConstructorFieldInit cfi | cfi.getTarget() = v and not cfi.isCompilerGenerated()) and
  // Ignore union members
  not v.getDeclaringType() instanceof Union
select v, "Variable " + v.getName() + " could be marked 'constexpr'."
