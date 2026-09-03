/**
 * @id c/cert/appropriate-storage-durations-function-return
 * @name DCL30-C: Declare objects with appropriate storage durations
 * @description When pointers to local variables are returned by a function it can lead to referring
 *              to objects outside of their lifetime, which is undefined behaviour.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/dcl30-c
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.ir.IR
import semmle.code.cpp.ir.dataflow.MustFlow
import PathGraph

/** Holds if `f` appears to intentionally return a stack pointer. */
predicate intentionallyReturnsStackPointer(Function f) {
  f.getName().toLowerCase().matches(["%stack%", "%sp%"])
}

/** Configuration for detecting stack-allocated memory returned by a function. */
class ReturnStackAllocatedMemoryConfig extends MustFlowConfiguration {
  ReturnStackAllocatedMemoryConfig() { this = "DCL30CReturnStackAllocatedMemoryConfig" }

  override predicate isSource(Instruction source) {
    exists(Function func |
      not func.hasErrors() and
      not intentionallyReturnsStackPointer(func) and
      func = source.getEnclosingFunction()
    |
      exists(VariableAddressInstruction var |
        var = source and
        var.getAstVariable() instanceof StackVariable and
        not var.getResultType() instanceof PointerToMemberType
      )
      or
      exists(Call call |
        call.getTarget().hasGlobalName(["alloca", "strdupa", "strndupa", "_alloca", "_malloca"]) and
        source.getUnconvertedResultExpression() = call
      )
    )
  }

  override predicate isSink(Operand sink) {
    exists(StoreInstruction store |
      store.getDestinationAddress().(VariableAddressInstruction).getIRVariable() instanceof
        IRReturnVariable and
      sink = store.getSourceValueOperand()
    )
  }

  override predicate allowInterproceduralFlow() { none() }

  override predicate isAdditionalFlowStep(Operand node1, Instruction node2) {
    node2.(FieldAddressInstruction).getObjectAddressOperand() = node1
    or
    node2.(PointerOffsetInstruction).getLeftOperand() = node1
  }

  override predicate isBarrier(Instruction n) { n.getResultType() instanceof ErroneousType }
}

from
  MustFlowPathNode source, MustFlowPathNode sink, Instruction instr,
  ReturnStackAllocatedMemoryConfig conf
where
  conf.hasFlowPath(pragma[only_bind_into](source), pragma[only_bind_into](sink)) and
  source.getInstruction() = instr and
  not isExcluded(sink.getInstruction().getAst(),
    Declarations8Package::appropriateStorageDurationsFunctionReturnQuery())
select sink.getInstruction(), source, sink,
  "$@ with automatic storage may be accessible outside of its lifetime.", instr.getAst(),
  instr.getAst().toString()
