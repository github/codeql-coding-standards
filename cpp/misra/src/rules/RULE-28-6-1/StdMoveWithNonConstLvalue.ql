/**
 * @id cpp/misra/std-move-with-non-const-lvalue
 * @name RULE-28-6-1: The argument to std::move shall be a non-const lvalue
 * @description Calling std::move on a const lvalue will not result in a move, and calling std::move
 *              on an rvalue is redundant.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-28-6-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.standardlibrary.Utility
import codingstandards.cpp.ast.ValueCategory
import codingstandards.cpp.types.Resolve
import codingstandards.cpp.types.Specifiers

predicate isConstLvalue(Expr arg) {
  getValueCategory(arg).isLValue() and
  arg.getType() instanceof ResolvesTo<RawConstType>::ExactlyOrRef
}

Type typeOfArgument(Expr e) {
  // An xvalue may be a constructor, which has no return type. However, these xvalues as act values
  // of the constructed type.
  if e instanceof ConstructorCall
  then result = e.(ConstructorCall).getTargetType()
  else result = e.getType()
}

from StdMoveCall call, Expr arg, string description
where
  arg = call.getArgument(0) and
  (
    isConstLvalue(arg) and
    description = "const " + getValueCategory(arg).toString()
    or
    getValueCategory(arg).isRValue() and
    description = getValueCategory(arg).toString()
  )
select call,
  "Call to 'std::move' with " + description + " argument of type '" + typeOfArgument(arg).toString()
    + "'."
