/**
 * @id cpp/autosar/semantic-equivalence-between-operator-form-not-preserved
 * @name M5-17-1: Semantic equivalence between a binary operator and its assignment operator shall be preserved
 * @description The semantic equivalence between a binary operator and its assignment operator form
 *              shall be preserved.  Where a set of operators is overloaded, the interactions
 *              between the operators must meet developer expectations.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-17-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

predicate hasAssignmentOperator(Type t) {
  exists(UserAssignmentOperator o | o.getDeclaringType() = t or t.refersTo(o.getDeclaringType()))
}

predicate hasEquivalentArithmeticAssignmentOperator(UserArithmeticOperator o) {
  exists(Operator assignOp |
    assignOp.getParameterString() = o.getParameterString() and
    assignOp.getType().stripType() = o.getType().stripType() and
    assignOp.hasName(o.getName() + "=")
  )
}

// if an arithmetic operator for a type has been declared, all of the following must be true:
// it must have an assignment operator
// it must have an arithmetic-assignment operator for that arithmetic operator, i.e. + and +=
from UserArithmeticOperator o
where
  not isExcluded(o,
    OperatorInvariantsPackage::semanticEquivalenceBetweenOperatorFormNotPreservedQuery()) and
  not (
    hasAssignmentOperator(o.getType().stripType()) and hasEquivalentArithmeticAssignmentOperator(o)
  )
select o,
  "Arithmetic Operator does not have a semantically equivalent assignment operator for type " +
    o.getType()
