/**
 * @id cpp/autosar/missing-const-operator-subscript
 * @name A13-5-1: If 'operator[]' is to be overloaded with a non-const version, const version shall also be
 * @description If 'operator[]' is to be overloaded with a non-const version, const version shall
 *              also be implemented.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a13-5-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Operator f
where
  not isExcluded(f, OperatorsPackage::missingConstOperatorSubscriptQuery()) and
  f.getName().matches("operator[]") and
  not f.hasSpecifier("const") and
  not exists(Operator constArrayOperator |
    constArrayOperator.getDeclaringType() = f.getDeclaringType() and
    constArrayOperator.getName().matches("operator[]") and
    constArrayOperator.hasSpecifier("const")
  )
select f,
  f.getDeclaringType().getName() +
    " declares a non-const 'operator[]' but does not declare a const 'operator[]'."
