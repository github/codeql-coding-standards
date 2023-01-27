/**
 * @id c/cert/incompatible-function-declarations
 * @name DCL40-C: Do not create incompatible declarations of the same function or object
 * @description Declaring incompatible functions, in other words same named function of different
 *              return types or with different numbers of parameters or parameter types, then
 *              accessing those functions can lead to undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/dcl40-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import ExternalIdentifiers

//checks if they are incompatible based on return type, number of parameters and parameter types
predicate checkMatchingFunction(FunctionDeclarationEntry d, FunctionDeclarationEntry d2) {
  not d.getType() = d2.getType()
  or
  not d.getNumberOfParameters() = d2.getNumberOfParameters()
  or
  exists(ParameterDeclarationEntry p, ParameterDeclarationEntry p2, int i |
    d.getParameterDeclarationEntry(i) = p and
    d2.getParameterDeclarationEntry(i) = p2 and
    not p.getType() = p2.getType()
  )
}

from ExternalIdentifiers d, FunctionDeclarationEntry f1, FunctionDeclarationEntry f2
where
  not isExcluded(f1, Declarations2Package::incompatibleFunctionDeclarationsQuery()) and
  not isExcluded(f2, Declarations2Package::incompatibleFunctionDeclarationsQuery()) and
  f1 = d.getADeclarationEntry() and
  f2 = d.getADeclarationEntry() and
  not f1 = f2 and
  f1.getLocation().getStartLine() >= f2.getLocation().getStartLine() and
  f1.getName() = f2.getName() and
  checkMatchingFunction(f1, f2)
select f1, "The object $@ is not compatible with re-declaration $@", f1, f1.getName(), f2,
  f2.getName()
