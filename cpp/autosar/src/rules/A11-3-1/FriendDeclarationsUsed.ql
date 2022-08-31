/**
 * @id cpp/autosar/friend-declarations-used
 * @name A11-3-1: Friend declarations shall not be used
 * @description Friend declarations shall not be used unless for comparison operators.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a11-3-1
 *       correctness
 *       security
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

predicate isComparisonOperator(FriendDecl f) {
  exists(UserComparisonOperator o | f.getFriend() = o)
}

from FriendDecl fd
where
  not isExcluded(fd, BannedSyntaxPackage::friendDeclarationsUsedQuery()) and
  not isComparisonOperator(fd)
select fd,
  fd.getFriend().getName() + " is declared as a friend of " + fd.getDeclaringClass().getName()
