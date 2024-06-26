/**
 * @id cpp/autosar/dynamic-type-of-this-used-from-constructor-or-destructor
 * @name M12-1-1: An object's dynamic type shall not be used from the body of its constructor or destructor
 * @description The dynamic type of an object is undefined during construction or destruction and
 *              must not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m12-1-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.objectsdynamictypeusedfromconstructorordestructor_shared.ObjectsDynamicTypeUsedFromConstructorOrDestructor_shared

class DynamicTypeOfThisUsedFromConstructorOrDestructorQuery extends ObjectsDynamicTypeUsedFromConstructorOrDestructor_sharedSharedQuery {
  DynamicTypeOfThisUsedFromConstructorOrDestructorQuery() {
    this = InheritancePackage::dynamicTypeOfThisUsedFromConstructorOrDestructorQuery()
  }
}
