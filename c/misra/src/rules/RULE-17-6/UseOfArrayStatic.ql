/**
 * @id c/misra/use-of-array-static
 * @name RULE-17-6: The declaration of an array parameter shall not contain the static keyword between the [ ]
 * @description Using the static keyword in an array type is error prone, and relies on the
 *              programmer to adhere to the guarantees to avoid undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-6
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra

from Parameter p
where
  not isExcluded(p, StaticPackage::useOfArrayStaticQuery()) and
  p.getType().(ArrayType).hasSpecifier("static")
select p, "Parameter " + p + " is declared as an array type using the static keyword."
