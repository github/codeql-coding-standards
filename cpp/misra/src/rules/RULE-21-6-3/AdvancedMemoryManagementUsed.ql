/**
 * @id cpp/misra/advanced-memory-management-used
 * @name RULE-21-6-3: Advanced memory management shall not be used
 * @description Using advanced memory management that either alters allocation and deallocation or
 *              constructs object construction on uninitalized memory may result in undefined
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.UnintializedMemoryAllocation
import codingstandards.cpp.allocations.CustomOperatorNewDelete

class NonStandardNewOrNewArrayOperator extends CustomOperatorNewOrDelete {
  NonStandardNewOrNewArrayOperator() {
    this.getName() in ["operator new", "operator new[]"] and
    not this instanceof CustomOperatorNew // `CustomOperatorNew` only detects replaceable allocation functions.
  }
}

class NonStandardDeleteOrDeleteArrayOperator extends CustomOperatorNewOrDelete {
  NonStandardDeleteOrDeleteArrayOperator() {
    this.getName() in ["operator delete", "operator delete[]"] and
    not this instanceof CustomOperatorDelete // `CustomOperatorDelete` only detects replaceable deallocation functions.
  }
}

from Element element
where
  not isExcluded(element, Memory6Package::advancedMemoryManagementUsedQuery()) and
  (
    /* The element is a call to one of the function at <memory> that manages uninitialized memory. */
    element.(FunctionCall).getTarget() instanceof UninitializedMemoryManagementFunction or
    /* The element is an explicit call to a destructor. */
    element instanceof VacuousDestructorCall or
    element instanceof DestructorCall or
    /* The element is a declaration or a definition of operator `new` / `new[]` / `delete` / `delete[]`. */
    element instanceof NonStandardNewOrNewArrayOperator or
    element instanceof NonStandardDeleteOrDeleteArrayOperator
  )
select element, "TODO"
