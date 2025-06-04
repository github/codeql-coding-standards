/**
 * @id cpp/cert/function-with-mismatched-language-linkage
 * @name EXP56-CPP: Do not call a function with a mismatched language linkage
 * @description A function with mismatched language linkage can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp56-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

from Function f, Type t, FunctionCall fc
where
  not isExcluded(f, FunctionsPackage::functionWithMismatchedLanguageLinkageQuery()) and
  t.stripType().(RoutineType).hasCLinkage() and
  f.getAParameter().getType() = t and
  f.getACallToThisFunction() = fc and
  not fc.getAnArgument().(FunctionAccess).getTarget().hasCLinkage()
select fc,
  "The language linkage of the function type used in the function access does not match the language linkage of the function definition."
