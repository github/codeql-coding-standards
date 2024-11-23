/**
 * @id c/misra/redeclaration-of-object-with-unmatched-alignment
 * @name RULE-8-15: Alignment should match between all declarations of an object
 * @description All declarations of an object with an explicit alignment specification shall specify
 *              the same alignment.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-15
 *       external/misra/c/2012/amendment3
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.valuenumbering.HashCons

predicate lexicallyEqual(AttributeArgument a, AttributeArgument b) {
  hashCons(a.getValueConstant()) = hashCons(b.getValueConstant()) or
  a.getValueType() = b.getValueType()
}

from Attribute alignment, Attribute mismatched, string variable
where
  not isExcluded(alignment, AlignmentPackage::redeclarationOfObjectWithUnmatchedAlignmentQuery()) and
  alignment.hasName("_Alignas") and
  mismatched.hasName("_Alignas") and
  exists(Variable v |
    v.getAnAttribute() = alignment and v.getAnAttribute() = mismatched and v.getName() = variable
  ) and
  not lexicallyEqual(alignment.getArgument(0), mismatched.getArgument(0))
select alignment,
  "Variable " + variable + " declared with lexically different _Alignof() values '$@' and '$@'.",
  alignment, alignment.getArgument(0).toString(), mismatched, mismatched.getArgument(0).toString()
