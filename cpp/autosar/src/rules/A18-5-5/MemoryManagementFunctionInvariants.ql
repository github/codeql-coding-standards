/**
 * @id cpp/autosar/memory-management-function-invariants
 * @name A18-5-5: Memory management functions must adhere to safe guidelines
 * @description Memory management functions shall ensure the following: (a) deterministic behavior
 *              resulting with the existence of worst-case execution time, (b) avoiding memory
 *              fragmentation, (c) avoid running out of memory, (d) 349 of 510 Document ID 839:
 *              AUTOSAR_RS_CPP14Guidelines.
 * @kind problem
 * @precision low
 * @problem.severity error
 * @tags external/autosar/id/a18-5-5
 *       correctness
 *       external/autosar/allocated-target/toolchain
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.allocations.UserDefinedMemoryAllocator

predicate isRecursive(UserDefinedMemoryAllocator ma, string msg) {
  exists(FunctionCall fc | fc.getEnclosingFunction() = ma and fc.getTarget() = ma) and
  msg = "Memory management function uses recursion."
}

predicate isEmpty(UserDefinedMemoryAllocator ma, string msg) {
  ma.getBlock().getNumStmt() = 1 and
  msg = "Memory management function is empty."
}

predicate resultDoesNotDependOnArgument(UserDefinedMemoryAllocator ma, string msg) {
  exists(Parameter p |
    p = ma.getParameter(0) and
    not exists(p.getAnAccess())
  ) and
  msg = "Memory management function does not depend on its argument."
}

predicate loopIsUnBounded(UserDefinedMemoryAllocator ma, string msg) {
  exists(Loop l |
    l.getEnclosingFunction() = ma and
    not exists(l.getCondition())
  ) and
  msg = "Loop within a user defined memory management function is unbounded."
}

predicate loopIsComplexUnBounded(UserDefinedMemoryAllocator ma, string msg) {
  exists(Loop l |
    l.getEnclosingFunction() = ma and
    exists(Expr e | e = l.getCondition().getAChild() and e instanceof FunctionCall)
  ) and
  msg =
    "Loop condition within a user defined memory management function defined depends on a complex condition."
}

from UserDefinedMemoryAllocator ma, string msg
where
  not isExcluded(ma, InvariantsPackage::memoryManagementFunctionInvariantsQuery()) and
  (
    isRecursive(ma, msg) or
    isEmpty(ma, msg) or
    resultDoesNotDependOnArgument(ma, msg) or
    loopIsUnBounded(ma, msg) or
    loopIsComplexUnBounded(ma, msg)
  )
select ma, msg
