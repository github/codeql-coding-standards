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

/*
 * This is a copy of the private `hasZeroParamDecl` predicate from the standard set of
 * queries as of the `codeql-cli/2.11.2` tag in `github/codeql`.
 */

predicate hasZeroParamDecl(Function f) {
  exists(FunctionDeclarationEntry fde | fde = f.getADeclarationEntry() |
    not fde.isImplicit() and
    not fde.hasVoidParamList() and
    fde.getNumberOfParameters() = 0 and
    not fde.isDefinition()
  )
}

from Function f, string msg
where
  not isExcluded(f, Declarations4Package::functionTypesNotInPrototypeFormQuery()) and
  f instanceof InterestingIdentifiers and
  (
    f.getAParameter() instanceof UnnamedParameter and
    msg = "Function " + f + " declares parameter that is unnamed."
    or
    hasZeroParamDecl(f) and
    msg = "Function " + f + " does not specifiy void for no parameters present."
    or
    //parameters declared in declaration list (not in function signature)
    //have placeholder file location associated only
    exists(Parameter p |
      p.getFunction() = f and
      not p.getFile() = f.getFile() and
      msg = "Function " + f + " declares parameter in unsupported declaration list."
    )
  )
select f, msg
