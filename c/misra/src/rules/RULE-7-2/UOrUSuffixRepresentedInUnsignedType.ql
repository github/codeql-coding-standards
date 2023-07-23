/**
 * @id c/misra/u-or-u-suffix-represented-in-unsigned-type
 * @name RULE-7-2: A 'U' or 'u' suffix shall be applied to all unsigned integers constants
 * @description A  'U' or 'u' suffix shall be applied to all integer constants that are represented
 *              in an unsigned type.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-7-2
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Literal l
where
  not isExcluded(l, SyntaxPackage::uOrUSuffixRepresentedInUnsignedTypeQuery()) and
  not l instanceof StringLiteral and
  l.getType().(IntegralType).isUnsigned() and
  not exists(l.getValueText().toUpperCase().indexOf("U")) and
  // We exclude literals in macros, as they are often expanded during pre-processing
  not l.isInMacroExpansion()
select l,
  "Unsigned literal " + l.getValueText() +
    " does not explicitly express sign with a 'U' or 'u' suffix."
