/**
 * @id c/misra/memcmp-used-to-compare-null-terminated-strings
 * @name RULE-21-14: The Standard Library function memcmp shall not be used to compare null terminated strings
 * @description Using memcmp to compare null terminated strings may give unexpected results because
 *              memcmp compares by size with no consideration for the null terminator.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-14
 *       maintainability
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import semmle.code.cpp.dataflow.TaintTracking
import NullTerminatedStringToMemcmpFlow::PathGraph

// Data flow from a StringLiteral or from an array of characters, to a memcmp call
module NullTerminatedStringToMemcmpConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof StringLiteral
    or
    exists(Variable v, ArrayAggregateLiteral aal |
      aal = v.getInitializer().getExpr() and
      // The array element type is an essentially character type
      getEssentialTypeCategory(aal.getElementType()) = EssentiallyCharacterType() and
      // Includes a null terminator somewhere in the array initializer
      aal.getAnElementExpr(_).getValue().toInt() = 0
    |
      // For local variables, use the array aggregate literal as the source
      aal = source.asExpr()
      or
      // ArrayAggregateLiterals used as initializers for global variables are not viable sources
      // for global data flow, so we instead report variable accesses as sources, where the variable
      // is constant or is not assigned in the program
      v instanceof GlobalVariable and
      source.asExpr() = v.getAnAccess() and
      (
        v.isConst()
        or
        not exists(Expr e | e = v.getAnAssignedValue() and not e = aal)
      )
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall memcmp |
      memcmp.getTarget().hasGlobalOrStdName("memcmp") and
      sink.asExpr() = memcmp.getArgument([0, 1])
    )
  }
}

module NullTerminatedStringToMemcmpFlow = TaintTracking::Global<NullTerminatedStringToMemcmpConfig>;

from
  FunctionCall memcmp, NullTerminatedStringToMemcmpFlow::PathNode source,
  NullTerminatedStringToMemcmpFlow::PathNode sink,
  NullTerminatedStringToMemcmpFlow::PathNode source1,
  NullTerminatedStringToMemcmpFlow::PathNode arg1,
  NullTerminatedStringToMemcmpFlow::PathNode source2,
  NullTerminatedStringToMemcmpFlow::PathNode arg2
where
  not isExcluded(memcmp, EssentialTypesPackage::memcmpUsedToCompareNullTerminatedStringsQuery()) and
  memcmp.getTarget().hasGlobalOrStdName("memcmp") and
  arg1.getNode().asExpr() = memcmp.getArgument(0) and
  arg2.getNode().asExpr() = memcmp.getArgument(1) and
  // There is a path from a null-terminated string to each argument
  NullTerminatedStringToMemcmpFlow::flowPath(source1, arg1) and
  NullTerminatedStringToMemcmpFlow::flowPath(source2, arg2) and
  // Produce multiple paths for each result, one for each source/arg pair
  (
    source = source1 and sink = arg1
    or
    source = source2 and sink = arg2
  )
select memcmp, source, sink, "memcmp used to compare $@ with $@.", source1,
  "null-terminated string", source2, "null-terminated string"
