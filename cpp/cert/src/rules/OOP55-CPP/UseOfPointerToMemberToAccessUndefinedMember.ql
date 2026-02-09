/**
 * @id cpp/cert/use-of-pointer-to-member-to-access-undefined-member
 * @name OOP55-CPP: Do not use a null pointer-to-member value in a pointer-to-member expression
 * @description The use of a null pointer-to-member value as the second operand in a
 *              pointer-to-member expression results in undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/oop55-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.accessofundefinedmemberthroughnullpointer.AccessOfUndefinedMemberThroughNullPointer

class UseOfPointerToMemberToAccessUndefinedMemberQuery extends AccessOfUndefinedMemberThroughNullPointerSharedQuery
{
  UseOfPointerToMemberToAccessUndefinedMemberQuery() {
    this = PointersPackage::useOfPointerToMemberToAccessUndefinedMemberQuery()
  }
}
