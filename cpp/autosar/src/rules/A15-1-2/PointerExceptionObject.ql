/**
 * @id cpp/autosar/pointer-exception-object
 * @name A15-1-2: An exception object shall not be a pointer
 * @description Throwing an exception of pointer type can lead to use-after-free or memory leak
 *              issues.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a15-1-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Expr thrownExpr
where
  not isExcluded(thrownExpr, Exceptions1Package::pointerExceptionObjectQuery()) and
  thrownExpr = any(ThrowExpr te).getExpr() and
  thrownExpr.getType().getUnspecifiedType() instanceof PointerType
select thrownExpr, "Exception object with pointer type " + thrownExpr.getType() + " is thrown here."
