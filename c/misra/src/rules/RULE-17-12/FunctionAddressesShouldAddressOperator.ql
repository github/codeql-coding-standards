/**
 * @id c/misra/function-addresses-should-address-operator
 * @name RULE-17-12: A function identifier should only be called with a parenthesized parameter list or used with a &
 * @description A function identifier should only be called with a parenthesized parameter list or
 *              used with a & (address-of).
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-12
 *       readability
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

predicate isImplicitlyAddressed(FunctionAccess access) {
  not access.getParent() instanceof AddressOfExpr and
  // Note: the following *seems* to only exist in c++ codebases, for instance,
  // when calling a member. In c, this syntax should always extract as a
  // [FunctionCall] rather than a [ExprCall] of a [FunctionAccess]. Still, this
  // is a good pattern to be defensive against.
  not exists(ExprCall call | call.getExpr() = access)
}

from FunctionAccess funcAccess
where
  not isExcluded(funcAccess, FunctionTypesPackage::functionAddressesShouldAddressOperatorQuery()) and
  isImplicitlyAddressed(funcAccess)
select funcAccess,
  "The address of function " + funcAccess.getTarget().getName() +
    " is taken without the & operator."
