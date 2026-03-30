/**
 * @id cpp/misra/invariant-condition
 * @name RULE-0-0-2: Controlling expressions should not be invariant
 * @description Invariant expressions in controlling statements can indicate logic errors or
 *              redundant code.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-0-0-2
 *       scope/system
 *       maintainability
 *       correctness
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Literals
import codingstandards.cpp.rules.invariantcondition.InvariantCondition

class WhileTrue extends WhileStmt {
  WhileTrue() { this.getCondition().(BoolLiteral).isTrue() }
}

class DoWhileFalse extends DoStmt {
  DoWhileFalse() { this.getCondition().(BoolLiteral).isFalse() }
}

module MisraConfig implements InvariantConditionConfigSig {
  Query getQuery() { result = DeadCode4Package::invariantConditionQuery() }

  predicate isException(ControlFlowNode node) {
    node.isAffectedByMacro() and
    node = any(DoWhileFalse dwf).getCondition()
    or
    node = any(WhileTrue wt).getCondition()
    or
    node = any(ConstexprIfStmt cifs).getCondition()
  }
}

// Import the problems query predicate
import InvariantCondition<MisraConfig>
