/**
 * @id cpp/autosar/non-identical-identifier-used-for-the-parameter-in-re-declaration-of-a-function
 * @name M8-4-2: The identifiers used for the parameters in a re-declaration of a function shall be identical
 * @description The identifiers used for the parameters in a re-declaration of a function shall be
 *              identical to those in the declaration.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m8-4-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from
  FunctionDeclarationEntry fde1, FunctionDeclarationEntry fde2, string ident1, string ident2, int n
where
  not isExcluded(fde1,
    NamingPackage::nonIdenticalIdentifierUsedForTheParameterInReDeclarationOfAFunctionQuery()) and
  not isExcluded(fde2,
    NamingPackage::nonIdenticalIdentifierUsedForTheParameterInReDeclarationOfAFunctionQuery()) and
  fde1.getDeclaration() = fde2.getDeclaration() and
  not fde1 = fde2 and
  ident1 = fde1.getParameterDeclarationEntry(n).getName() and
  ident2 = fde2.getParameterDeclarationEntry(n).getName() and
  not ident1 = ident2 and
  not ident1 = "" and
  not ident2 = "" and
  (
    fde1.getFile().getAbsolutePath() < fde2.getFile().getAbsolutePath()
    or
    fde1.getFile().getAbsolutePath() = fde2.getFile().getAbsolutePath() and
    fde1.getLocation().getStartLine() < fde2.getLocation().getStartLine()
  )
select fde2.getLocation(),
  "The re-declaration of $@ uses a non-identical parameter identifier " + ident2 + " instead of " +
    ident1 + " for the " + n + "th parameter.", fde1.getLocation(),
  fde1.getDeclaration().getQualifiedName()
