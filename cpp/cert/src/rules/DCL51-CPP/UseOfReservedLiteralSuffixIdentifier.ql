/**
 * @id cpp/cert/use-of-reserved-literal-suffix-identifier
 * @name DCL51-CPP: Use of reserved literal suffix identifier
 * @description Literal suffix identifiers that do not start with an underscore are reserved for
 *              future standardization.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl51-cpp
 *       maintainability
 *       readability
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.UserDefinedLiteral

from UserDefinedLiteral udl
where
  not isExcluded(udl, NamingPackage::useOfReservedLiteralSuffixIdentifierQuery()) and
  not udl.hasCompliantSuffix()
select udl, "Literal suffix identifier $@ does not start with an underscore.", udl, udl.getName()
