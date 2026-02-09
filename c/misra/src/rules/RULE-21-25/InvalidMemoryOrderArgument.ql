/**
 * @id c/misra/invalid-memory-order-argument
 * @name RULE-21-25: All memory synchronization operations shall be executed in sequentially consistent order
 * @description Only the memory ordering of 'memory_order_seq_cst' is fully portable and consistent.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-25
 *       external/misra/c/2012/amendment4
 *       correctness
 *       concurrency
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.StdFunctionOrMacro
import semmle.code.cpp.dataflow.new.DataFlow

class MemoryOrderEnum extends Enum {
  MemoryOrderEnum() {
    this.hasGlobalOrStdName("memory_order")
    or
    exists(TypedefType t |
      t.getName() = "memory_order" and
      t.getBaseType() = this
    )
  }
}

/* A member of the set of memory orders defined in the `memory_order` enum */
class MemoryOrder extends EnumConstant {
  MemoryOrder() { getDeclaringEnum() instanceof MemoryOrderEnum }

  int getIntValue() { result = getValue().toInt() }
}

/* This is the only standardized memory order, allowed by RULE-21-25. */
class AllowedMemoryOrder extends MemoryOrder {
  AllowedMemoryOrder() { getName() = "memory_order_seq_cst" }
}

/* An expression referring to a memory order */
class MemoryOrderConstantAccess extends EnumConstantAccess {
  MemoryOrderConstantAccess() { getTarget() instanceof MemoryOrder }

  predicate isAllowedOrder() { getTarget() instanceof AllowedMemoryOrder }
}

/* An expression with a constant value that equals a `MemoryOrder` constant */
class MemoryOrderConstantExpr extends Expr {
  MemoryOrder ord;

  MemoryOrderConstantExpr() {
    if this instanceof MemoryOrderConstantAccess
    then ord = this.(MemoryOrderConstantAccess).getTarget()
    else ord.getIntValue() = getValue().toInt()
  }

  /* Get the name of the `MemoryOrder` this expression is valued as. */
  string getMemoryOrderString() { result = ord.getName() }
}

module MemoryOrderFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    // Direct usage of memory order constant
    exists(MemoryOrderConstantAccess constant |
      node.asExpr() = constant and
      not constant.isAllowedOrder()
    )
    or
    // A literal with a disallowed constant integer value
    exists(Literal literal |
      node.asExpr() = literal and
      not literal.getValue().toInt() = any(AllowedMemoryOrder a).getValue().toInt()
    )
  }

  predicate isSink(DataFlow::Node node) {
    exists(AtomicallySequencedCall call | call.getAMemoryOrderArgument() = node.asExpr())
  }
}

module MemoryOrderFlow = DataFlow::Global<MemoryOrderFlowConfig>;

import MemoryOrderFlow::PathGraph

/**
 * If the node is a memory order constant, or shares a value with a memory order constant, then
 * return the name of that constant. Otherwise, simply print the node.
 */
string describeMemoryOrderNode(DataFlow::Node node) {
  if node.asExpr() instanceof MemoryOrderConstantExpr
  then result = node.asExpr().(MemoryOrderConstantExpr).getMemoryOrderString()
  else result = node.toString()
}

from
  Expr argument, AtomicallySequencedCall function, string value, MemoryOrderFlow::PathNode source,
  MemoryOrderFlow::PathNode sink
where
  not isExcluded(argument, Concurrency6Package::invalidMemoryOrderArgumentQuery()) and
  MemoryOrderFlow::flowPath(source, sink) and
  argument = sink.getNode().asExpr() and
  value = describeMemoryOrderNode(source.getNode()) and
  // Double check that we didn't find flow from something equivalent to the allowed value.
  not value = any(AllowedMemoryOrder e).getName() and
  function.getAMemoryOrderArgument() = argument
select argument, source, sink, "Invalid memory order '$@' in call to function '$@'.", value, value,
  function, function.getName()
