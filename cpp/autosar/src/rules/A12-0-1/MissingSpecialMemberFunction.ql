/**
 * @id cpp/autosar/missing-special-member-function
 * @name A12-0-1: If a class declares a copy or move operation, or a destructor, either via '=default', '=delete', or
 * @description If a class declares a copy or move operation, or a destructor, either via
 *              '=default', '=delete', or via a user-provided declaration, then all others of these
 *              five special member functions shall be declared as well.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-0-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class

MemberFunction getANonCompilerGeneratedMemberFunction(Class c) {
  result = c.getAMemberFunction() and not result.isCompilerGenerated()
}

class ClassWithFullySpecifiedSpecialMemberFunctions extends Class {
  ClassWithFullySpecifiedSpecialMemberFunctions() {
    // this explicit comparison is necessary because multiple definitions
    // may exist for some functions, e.g., the copy assignment operator may
    // have more than one form defined per class.
    getANonCompilerGeneratedMemberFunction(this) instanceof CopyConstructor and
    getANonCompilerGeneratedMemberFunction(this) instanceof MoveConstructor and
    getANonCompilerGeneratedMemberFunction(this) instanceof CopyAssignmentOperator and
    getANonCompilerGeneratedMemberFunction(this) instanceof MoveAssignmentOperator and
    getANonCompilerGeneratedMemberFunction(this) instanceof Destructor
  }
}

from Class c
where
  not isExcluded(c, ClassesPackage::missingSpecialMemberFunctionQuery()) and
  // At least one special member function is explicitly declared
  exists(UserDefinedSpecialMemberFunction specialMemberFunction |
    specialMemberFunction = c.getAMemberFunction()
  |
    not specialMemberFunction instanceof Constructor
    or
    specialMemberFunction instanceof CopyConstructor
    or
    specialMemberFunction instanceof MoveConstructor
  ) and
  // But not all special member functions are declared
  not c instanceof ClassWithFullySpecifiedSpecialMemberFunctions
select c,
  "Class $@ has provided at least one user-defined special member function but is missing definitions for all five special member functions.",
  c, c.getName()
