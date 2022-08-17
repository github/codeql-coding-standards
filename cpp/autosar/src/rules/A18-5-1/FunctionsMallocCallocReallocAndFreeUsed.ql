/**
 * @id cpp/autosar/functions-malloc-calloc-realloc-and-free-used
 * @name A18-5-1: Functions malloc, calloc, realloc and free shall not be used
 * @description C-style memory allocation and deallocation functions malloc, calloc, realloc and
 *              free shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-5-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isMemAlloc(FunctionCall fc) {
  fc.getTarget().hasGlobalOrStdName(["malloc", "calloc", "realloc", "free"])
}

from FunctionCall fc
where
  isMemAlloc(fc) and
  not isExcluded(fc, BannedFunctionsPackage::functionsMallocCallocReallocAndFreeUsedQuery())
select fc, "Use of banned function " + fc.getTarget().getQualifiedName() + "."
