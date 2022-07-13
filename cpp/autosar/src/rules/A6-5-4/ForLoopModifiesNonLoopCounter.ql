/**
 * @id cpp/autosar/for-loop-modifies-non-loop-counter
 * @name A6-5-4: For statement expressions should not perform actions other than loop-counter modification
 * @description For-init-statement and expression should not perform actions other than loop-counter
 *              initialization and modification.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a6-5-4
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Loops

private Expr getAnUpdateOperand(ForStmt fs) {
  exists(Expr e | e = fs.getUpdate().getAChild*() |
    // Incremented
    result = e.(CrementOperation).getOperand()
    or
    // Call to operator++ or operator--
    exists(Call c |
      c = e and
      c.getTarget().(Operator).hasName(["operator++", "operator--"]) and
      result = c.getQualifier()
    )
    or
    // Assigned to
    result = e.(Assignment).getLValue()
  )
}

from ForStmt fs, Variable v
where
  not isExcluded(fs, LoopsPackage::forLoopModifiesNonLoopCounterQuery()) and
  v = getAnIterationVariable(fs) and
  not exists(VariableAccess va | va = v.getAnAccess() and va = getAnUpdateOperand(fs))
select fs, "For-loop counter $@ is not modified in the update expression of the loop.", v,
  v.getName()
