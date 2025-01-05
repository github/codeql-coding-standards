/**
 * @id c/misra/alignment-with-size-zero
 * @name RULE-8-16: The alignment specification of zero should not appear in an object declaration
 * @description A declaration shall not have an alignment of size zero.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-16
 *       external/misra/c/2012/amendment3
 *       readability
 *       maintainability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Attribute a, Variable v
where
  not isExcluded(a, AlignmentPackage::alignmentWithSizeZeroQuery()) and
  a.hasName("_Alignas") and
  a.getArgument(0).getValueInt() = 0 and
  v.getAnAttribute() = a
select a.getArgument(0), "Invalid alignof() size set to zero for variable $@.", v, v.getName()
