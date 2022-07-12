/**
 * @id cpp/autosar/explicit-construction-of-unnamed-temporary
 * @name A6-2-2: Expression statements shall not be explicit calls to constructors of temporary objects only
 * @description The explicit creation of a temporary object without usage that will be destroyed at
 *              the end of the full expression might be inconsistent with the developer's
 *              intentions.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a6-2-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from ExprStmt s
where
  not isExcluded(s, OrderOfEvaluationPackage::explicitConstructionOfUnnamedTemporaryQuery()) and
  s.getExpr() instanceof ConstructorCall
select s, "Expression statement is an explicit call to a constructor of an unused temporary object."
