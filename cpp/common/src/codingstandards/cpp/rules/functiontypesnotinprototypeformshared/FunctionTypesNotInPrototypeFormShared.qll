/**
 * Provides a library with a `problems` predicate for the following issue:
 * The use of non-prototype format parameter type declarators is an obsolescent
 * language feature.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Identifiers

abstract class FunctionTypesNotInPrototypeFormSharedSharedQuery extends Query { }

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

Query getQuery() { result instanceof FunctionTypesNotInPrototypeFormSharedSharedQuery }

query predicate problems(Function f, string msg) {
  not isExcluded(f, getQuery()) and
  f instanceof InterestingIdentifiers and
  (
    f.getAParameter() instanceof UnnamedParameter and
    msg = "Function " + f + " declares parameter that is unnamed."
    or
    hasZeroParamDecl(f) and
    msg = "Function " + f + " does not specify void for no parameters present."
    or
    //parameters declared in declaration list (not in function signature)
    //have no prototype
    not f.isPrototyped() and
    not hasZeroParamDecl(f) and
    msg = "Function " + f + " declares parameter in unsupported declaration list."
  )
}
