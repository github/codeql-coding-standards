/**
 * @id cpp/misra/pointer-arithmetic-forms-an-invalid-pointer
 * @name RULE-8-7-1: Pointer arithmetic shall not form an invalid pointer.
 * @description Pointers obtained as result of performing arithmetic should point to an initialized
 *              object, or an element right next to the last element of an array.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-7-1
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import semmle.code.cpp.dataflow.new.DataFlow

module TrackArrayConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    /* 1. Declaring an array-type variable */
    none()
    or
    /* 2. Allocating dynamic memory as an array */
    none()
  }

  predicate isSink(DataFlow::Node node) {
    /* 1. Pointer arithmetic */
    none()
    or
    /* 2. Array access */
    none()
  }
}

module TrackArray = DataFlow::Global<TrackArrayConfig>;

from Expr expr
where
  not isExcluded(expr, Memory1Package::pointerArithmeticFormsAnInvalidPointerQuery()) and
  none() // TODO
select "TODO", "TODO"
