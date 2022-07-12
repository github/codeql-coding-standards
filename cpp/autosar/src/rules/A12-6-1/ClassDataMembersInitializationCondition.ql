/**
 * @id cpp/autosar/class-data-members-initialization-condition
 * @name A12-6-1: All class data members that are initialized by the constructor shall be initialized using member initializers
 * @description All class data members that are initialized by the constructor shall be initialized
 *              using member initializers.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-6-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class ConstructorAssignedField extends Field {
  Constructor constructor;
  AssignExpr aexp;

  ConstructorAssignedField() {
    constructor.getDeclaringType().getAField() = this and
    aexp.getEnclosingFunction() = constructor and
    aexp = this.getAnAssignment()
  }

  Constructor getAConstructor() { result = constructor }

  AssignExpr getAConstructorAssignment() { result = aexp }
}

from Constructor c, ConstructorAssignedField f
where
  not isExcluded(c, ClassesPackage::classDataMembersInitializationConditionQuery()) and
  c = f.getAConstructor() and
  not exists(ConstructorFieldInit fi |
    fi = c.getAnInitializer() and
    fi.getTarget() = f
  )
select c, "Constructor $@ without using a member initializer", f.getAConstructorAssignment(),
  "initializes a data member"
