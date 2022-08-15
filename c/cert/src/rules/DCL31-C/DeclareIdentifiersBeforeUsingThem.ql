/**
 * @id c/cert/declare-identifiers-before-using-them
 * @name DCL31-C: Declare identifiers before using them
 * @description Omission of type specifiers may not be supported by some
 * compilers.
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
  d.hasSpecifier("implicit_int") and
  exists(Type t |
    (d.(Variable).getType() = t or d.(Function).getType() = t) and
    // Exclude "short" or "long", as opposed to "short int" or "long int".
    t instanceof IntType and
    // Exclude "signed" or "unsigned", as opposed to "signed int" or "unsigned int".
    not exists(IntegralType it | it = t | it.isExplicitlySigned() or it.isExplicitlyUnsigned())
  )
select d, "Declaration is missing a type specifier."
