/**
 * @id c/misra/function-types-not-in-prototype-form
 * @name RULE-8-2: Function types shall be in prototype form with named parameters
 * @description Omission of parameter types or names prevents the compiler from doing type checking
 *              when those functions are used and therefore may result in undefined behaviour.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-8-2
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers

/**
 * `Parameter`s without names
 */
class UnnamedParameter extends Parameter {
  UnnamedParameter() { not this.isNamed() }
}

from Function f, string msg
where
  not isExcluded(f, Declarations4Package::functionTypesNotInPrototypeFormQuery()) and
  f instanceof InterestingIdentifiers and
  (
    f.getAParameter() instanceof UnnamedParameter and
    msg = "Function " + f + " declares parameter that is unnamed."
    or
    //void keyword not present in function signature, no way to tell which
    not exists(f.getAParameter()) and
    msg =
      "Function " + f +
        " may not specify all parameter types or may not specifiy void for no parameters present."
    or
    exists(Parameter p |
      p.getFunction() = f and
      not p.getFile() = f.getFile() and
      msg = "Function " + f + " declares parameter in unsupported declaration list."
    )
  ) and
  not f.isInMacroExpansion()
select f, msg
