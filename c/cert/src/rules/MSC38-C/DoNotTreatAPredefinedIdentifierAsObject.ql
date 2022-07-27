/**
 * @id c/cert/do-not-treat-a-predefined-identifier-as-object
 * @name MSC38-C: Do not treat a predefined identifier as an object if it might only be implemented as a macro
 * @description Accessing an object or function that expands to one of a few specific standard
 *              library macros is undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/msc38-c
 *       correctness
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

predicate hasRestrictedMacroName(string s) {
  s = "assert"
  or
  s = "errno"
  or
  s = "math_errhandling"
  or
  s = "setjmp"
  or
  s = "va_arg"
  or
  s = "va_copy"
  or
  s = "va_end"
  or
  s = "va_start"
}

from Element m, string name
where
  not isExcluded(m, Preprocessor5Package::doNotTreatAPredefinedIdentifierAsObjectQuery()) and
  (
    m.(Access).getTarget().hasName(name)
    or
    m.(Declaration).hasGlobalName(name)
  ) and
  hasRestrictedMacroName(name)
select m, "Supression of standard library macro " + name + "."
