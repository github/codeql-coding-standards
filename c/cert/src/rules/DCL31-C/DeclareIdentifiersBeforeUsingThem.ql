/**
 * @id c/cert/declare-identifiers-before-using-them
 * @name DCL31-C: Declare identifiers before using them
 * @description Omission of type specifiers may not be supported by some compilers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl31-c
 *       correctness
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from Declaration d
where
  not isExcluded(d, Declarations1Package::declareIdentifiersBeforeUsingThemQuery()) and
  exists(Specifier s | s = d.getASpecifier() and s.toString() = "implicit_int") and
  exists(d.getFile().getRelativePath())
select d, "Declaration is missing a type specifier."
