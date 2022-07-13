/**
 * @id cpp/autosar/parameter-not-passed-by-reference
 * @name A8-4-10: A parameter shall be passed by reference if it can't be NULL
 * @description Passing by reference for parameters which cannot be NULL provides a clearer
 *              interface.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a8-4-10
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Dereferenced
import semmle.code.cpp.controlflow.Nullness

from Parameter p
where
  not isExcluded(p, NullPackage::parameterNotPassedByReferenceQuery()) and
  // Pointer type parameter
  p.getUnspecifiedType() instanceof PointerType and
  // Dereferenced at least once
  p.getAnAccess() instanceof DereferencedExpr and
  // Never null checked
  not nullCheckExpr(_, p) and
  // Never not-null checked
  not validCheckExpr(_, p)
select p,
  "Parameter " + p.getName() +
    " is always dereferenced and therefore cannot be null but is a pointer parameter."
