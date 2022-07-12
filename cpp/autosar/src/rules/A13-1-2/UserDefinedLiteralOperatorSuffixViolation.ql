/**
 * @id cpp/autosar/user-defined-literal-operator-suffix-violation
 * @name A13-1-2: User defined suffixes of user defined literal operator syntax requirement
 * @description User defined suffixes of the user defined literal operators shall start with
 *              underscore followed by one or more letters.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a13-1-2
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.UserDefinedLiteral

from UserDefinedLiteral udl
where
  not isExcluded(udl, NamingPackage::userDefinedLiteralOperatorSuffixViolationQuery()) and
  not udl.hasCompliantSuffix()
select udl,
  "User defined literal operator should start with an underscore followed by one or more letters"
