/**
 * @id c/misra/do-not-use-addition-or-subtraction-operators-on-pointers
 * @name RULE-18-4: The +, -, += and -= operators should not be applied to an expression of pointer type
 * @description Array indexing should be used to perform pointer arithmetic as it is less prone to
 *              errors and undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-18-4
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.useonlyarrayindexingforpointerarithmetic.UseOnlyArrayIndexingForPointerArithmetic

class DoNotUseAdditionOrSubtractionOperatorsOnPointersQuery extends UseOnlyArrayIndexingForPointerArithmeticSharedQuery {
  DoNotUseAdditionOrSubtractionOperatorsOnPointersQuery() {
    this = Pointers1Package::doNotUseAdditionOrSubtractionOperatorsOnPointersQuery()
  }
}
