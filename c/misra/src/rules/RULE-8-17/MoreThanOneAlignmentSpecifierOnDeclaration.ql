/**
 * @id c/misra/more-than-one-alignment-specifier-on-declaration
 * @name RULE-8-17: At most one explicit alignment specifier should appear in an object declaration
 * @description While C permits the usage of multiple alignment specifiers, doing so reduces
 *              readability and may obscure the intent of the declaration.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-17
 *       external/misra/c/2012/amendment3
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Variable v, Attribute first, Attribute last
where
  not isExcluded(v, AlignmentPackage::moreThanOneAlignmentSpecifierOnDeclarationQuery()) and
  first = v.getAnAttribute() and
  last = v.getAnAttribute() and
  not first = last and
  first.hasName("_Alignas") and
  last.hasName("_Alignas") and
  // Handle double reporting: the first Attribute should really be first, and the last Attribute
  // should really be last. This implies the first is before the last. This approach also ensures
  // a single result for variables that have more than two alignment specifiers.
  not exists(Attribute beforeFirst |
    beforeFirst.getLocation().isBefore(first.getLocation(), _) and
    v.getAnAttribute() = beforeFirst
  ) and
  not exists(Attribute afterLast |
    last.getLocation().isBefore(afterLast.getLocation(), _) and
    v.getAnAttribute() = afterLast
  )
select v, "Variable " + v.getName() + " contains more than one alignment specifier, $@ and $@",
  first, first.toString(), last, last.toString()
