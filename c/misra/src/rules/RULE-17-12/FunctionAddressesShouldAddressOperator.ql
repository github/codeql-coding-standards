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
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

abstract class AddressOfFunction extends Expr {
  abstract predicate isImplicitlyAddressed();

  abstract string getFuncName();
}

class FunctionTypeAccess extends FunctionAccess, AddressOfFunction {

  predicate isImmediatelyParenthesized() {
    exists(ParenthesisExpr parens | parens.getExpr() = this)
  }

  predicate isExplicitlyAddressed() {
    getParent() instanceof AddressOfExpr and
    not isImmediatelyParenthesized()
  }

  override predicate isImplicitlyAddressed() {
    not isExplicitlyAddressed()
  }

  override string getFuncName() {
    result = getTarget().getName()
  }
}

/*
class IndirectFunctionCall extends FunctionCall, AddressOfFunction {
  override predicate isImplicitlyAddressed() {
    getConversion+() instanceof ParenthesisExpr
  }
  
  override string getFuncName() {
    result = getTarget().getName()
  }
}
  */

class MacroArgTakesFunction extends AddressOfFunction {
  MacroInvocation m;
  MacroArgTakesFunction() {
    m.getExpr() = this
  }

  override predicate isImplicitlyAddressed() {
    any()
  }

  string getProp() {
    result = m.getExpandedArgument(_)
    and this.get
  }

  override string getFuncName() {
    result = "a macro argument"
  }

}

from AddressOfFunction funcAddr
where
  not isExcluded(funcAddr, FunctionTypesPackage::functionAddressesShouldAddressOperatorQuery()) and
  //not funcAccess.isImmediatelyCalled() and
  //not funcAccess.isExplicitlyAddressed()
  funcAddr.isImplicitlyAddressed()
select
  funcAddr, "The address of function " + funcAddr.getFuncName() + " is taken without the & operator."