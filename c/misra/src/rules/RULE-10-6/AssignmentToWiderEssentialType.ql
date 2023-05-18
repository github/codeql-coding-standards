/**
 * @id c/misra/assignment-to-wider-essential-type
 * @name RULE-10-6: The value of a composite expression shall not be assigned to an object with wider essential type
 * @description Assigning a composite expression to an object with wider essential type can cause
 *              some unexpected conversions.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-6
 *       maintainability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import codingstandards.c.misra.MisraExpressions

from CompositeExpression ce, Type lValueType, Type compositeEssentialType
where
  not isExcluded(ce, EssentialTypesPackage::assignmentToWiderEssentialTypeQuery()) and
  isAssignmentToEssentialType(lValueType, ce) and
  compositeEssentialType = getEssentialType(ce) and
  lValueType.getSize() > compositeEssentialType.getSize() and
  // Assignment to a different type category is prohibited by Rule 10.3, so we only report cases
  // where the assignment is to the same type category.
  getEssentialTypeCategory(lValueType) = getEssentialTypeCategory(compositeEssentialType)
select ce, "Assignment to wider essential type `" + lValueType.getName() + "`."
