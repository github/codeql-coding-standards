/**
 * @id c/misra/array-function-argument-number-of-elements
 * @name RULE-17-5: An array founction argument shall have an appropriate number of elements
 * @description The function argument corresponding to an array parameter shall have an appropriate
 *              number of elements.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-17-5
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.dataflow.new.DataFlow

/**
 * Models a function parameter of type array with specified size
 * ```
 * void f1(int ar[3]);
 * ```
 */
class ArrayParameter extends Parameter {
  ArrayParameter() { this.getType().(ArrayType).hasArraySize() }

  Expr getAMatchingArgument() {
    exists(FunctionCall fc |
      this.getFunction() = fc.getTarget() and
      result = fc.getArgument(this.getIndex())
    )
  }

  int getArraySize() { result = this.getType().(ArrayType).getArraySize() }
}

/**
 * The number of initialized elements in an ArrayAggregateLiteral.
 * In the following examples the result=2
 * ```
 * int arr3[3] = {1, 2};
 * int arr2[2] = {1, 2, 3};
 * ```
 */
int countElements(ArrayAggregateLiteral l) { result = count(l.getAnElementExpr(_)) }

module SmallArrayConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) { src.asExpr() instanceof ArrayAggregateLiteral }

  predicate isSink(DataFlow::Node sink) {
    sink.asIndirectExpr() = any(ArrayParameter p).getAMatchingArgument()
  }
}

module SmallArrayFlow = DataFlow::Global<SmallArrayConfig>;

from Expr arg, ArrayParameter p
where
  not isExcluded(arg, Contracts6Package::arrayFunctionArgumentNumberOfElementsQuery()) and
  arg = p.getAMatchingArgument() and
  (
    // the argument is a value and not an array
    not arg.getType() instanceof DerivedType
    or
    // the argument is an array too small
    arg.getType().(ArrayType).getArraySize() < p.getArraySize()
    or
    // the argument is a pointer and its value does not come from a literal of the correct
    arg.getType() instanceof PointerType and
    not exists(ArrayAggregateLiteral l, DataFlow::Node arg_node | arg_node.asIndirectExpr() = arg |
      SmallArrayFlow::flow(DataFlow::exprNode(l), arg_node) and
      countElements(l) >= p.getArraySize()
    )
  )
select arg,
  "The function argument does not have a sufficient number or elements declared in the $@.", p,
  "parameter"
