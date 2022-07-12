/**
 * Additional CFG edge from one field initialiazation to the next
 * and to the function body
 */

import cpp
import codingstandards.cpp.exceptions.ExceptionFlow

class ConstructorInitEdge extends AdditionalControlFlowEdge {
  ConstructorFieldInit init;

  ConstructorInitEdge() { init.getExpr() = this }

  override ControlFlowNode getAnEdgeTarget() {
    exists(Constructor c, int i |
      init = c.getInitializer(i) and
      if exists(c.getInitializer(i + 1))
      then result = c.getInitializer(i + 1).(ConstructorFieldInit).getExpr()
      else result = c.getEntryPoint()
    )
  }
}

// Additional CFG edge from throwing function to catch block
class ThrowCatchEdge extends AdditionalControlFlowEdge {
  ControlFlowNode target;

  ThrowCatchEdge() { catches(target, this, _) }

  override ControlFlowNode getAnEdgeTarget() { result = target }
}
