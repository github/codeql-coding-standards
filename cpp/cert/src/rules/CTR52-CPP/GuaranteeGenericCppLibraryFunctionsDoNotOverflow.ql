/**
 * @id cpp/cert/guarantee-generic-cpp-library-functions-do-not-overflow
 * @name CTR52-CPP: Guarantee that C++ library functions do not overflow
 * @description Guarantee that the C++ generic library functions do not overflow.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/ctr52-cpp
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Iterators
import codingstandards.cpp.rules.containeraccesswithoutrangecheck.ContainerAccessWithoutRangeCheck as ContainerAccessWithoutRangeCheck
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

/**
 * A generic function call that writes out to an iterator and may cause overflow due to a lack of
 * bounds checking.
 */
class OutputIteratorFunctionCall extends FunctionCall {
  Expr inputArgument;
  Expr outputArgument;

  OutputIteratorFunctionCall() {
    exists(string iteratorOverflowAPI |
      // We use a CSV format to describe the various APIs in the C++ standard library that accept
      // iterators. The format is:
      //
      //  name,number of parameters,index of first input iterator,index of first output iterator
      //
      iteratorOverflowAPI =
        [
          "copy,*,0,2", "copy_n,*,0,2", "copy_if,*,0,2", "copy_backward,*,0,2", "move,*,0,2",
          "move_backward,*,0,2", "transform,4,0,2", "transform,5,0,3", "replace_copy,*,0,2",
          "replace_copy_if,*,0,2", "remove_copy,*,0,2", "remove_copy_if,*,0,2", "unique_copy,*,0,2",
          "reverse_copy,*,0,2", "partition_copy,*,0,2", "partial_sort_copy,*,0,2",
          "rotate_copy,*,0,3", "merge,*,0,4", "set_union,*,0,4", "set_intersection,*,0,4",
          "set_difference,*,0,4", "set_symmetric_difference,*,0,4"
        ]
    |
      getTarget().hasQualifiedName("std", iteratorOverflowAPI.splitAt(",", 0)) and
      inputArgument = getArgument(iteratorOverflowAPI.splitAt(",", 2).toInt()) and
      outputArgument = getArgument(iteratorOverflowAPI.splitAt(",", 3).toInt()) and
      exists(string numberOfParams | numberOfParams = iteratorOverflowAPI.splitAt(",", 1) |
        numberOfParams = "*"
        or
        getTarget().getNumberOfParameters() = numberOfParams.toInt()
      )
    )
  }

  /** Gets the first argument representing the input iterator. */
  Expr getInputIterator() { result = inputArgument }

  /** Gets a source of the input iterator for this call. */
  IteratorSource getInputIteratorSource() { result.sourceFor(getInputIterator()) }

  /** Gets the first argument representing the output iterator. */
  Expr getOutputIterator() { result = outputArgument }

  /** Gets a source of the output iterator for this call. */
  IteratorSource getOutputIteratorSource() { result.sourceFor(getOutputIterator()) }
}

from OutputIteratorFunctionCall c
where
  not isExcluded(c, OutOfBoundsPackage::guaranteeGenericCppLibraryFunctionsDoNotOverflowQuery()) and
  not c.getOutputIteratorSource()
      .(FunctionCall)
      .getTarget()
      .hasQualifiedName("std", ["back_inserter", "front_inserter"]) and
  // Exclude cases where the container is bounds checked, or initialized to a viable size
  not exists(STLContainer outputContainer, FunctionCall iteratorCreationCall |
    iteratorCreationCall = outputContainer.getAnIteratorFunctionCall() and
    iteratorCreationCall = c.getOutputIteratorSource()
  |
    sizeCompareBoundsChecked(iteratorCreationCall, c)
    or
    // Container created with sufficient size for the input
    exists(ContainerAccessWithoutRangeCheck::ContainerConstructorCall outputIteratorConstructor |
      // Use local flow to find allocations which reach this qualifier without redefinition
      DataFlow::localFlow(DataFlow::exprNode(outputIteratorConstructor),
        DataFlow::exprNode(iteratorCreationCall.getQualifier()))
    |
      // The initial size of the destination container is fixed, and is larger than the input container initial size
      exists(ContainerAccessWithoutRangeCheck::ContainerConstructorCall inputIteratorConstructor |
        DataFlow::localFlow(DataFlow::exprNode(inputIteratorConstructor),
          DataFlow::exprNode(c.getInputIteratorSource().getQualifier())) and
        outputIteratorConstructor.getInitialContainerSize() >=
          inputIteratorConstructor.getInitialContainerSize()
      )
      or
      // The initial size of the destination container is derived from the size of the input container
      exists(Expr iteratorAccess, ContainerAccessWithoutRangeCheck::ContainerSizeCall sizeCall |
        globalValueNumber(c.getInputIteratorSource().getQualifier()) =
          globalValueNumber(iteratorAccess) and
        sizeCall.getQualifier() = iteratorAccess and
        TaintTracking::localTaint(DataFlow::exprNode(sizeCall),
          DataFlow::exprNode(outputIteratorConstructor.getInitialContainerSizeExpr()))
      )
    )
  )
select c.getOutputIterator(),
  "Output iterator for $@ is not guaranteed to be large enough for the input iterator.", c,
  c.toString()
