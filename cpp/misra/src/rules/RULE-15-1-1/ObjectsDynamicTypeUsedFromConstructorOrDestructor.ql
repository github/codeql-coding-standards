/**
 * @id cpp/misra/objects-dynamic-type-used-from-constructor-or-destructor
 * @name RULE-15-1-1: An object’s dynamic type shall not be used from within its constructor or destructor
 * @description An object’s dynamic type shall not be used from within its constructor or
 *              destructor.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-15-1-1
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.objectsdynamictypeusedfromconstructorordestructor.ObjectsDynamicTypeUsedFromConstructorOrDestructor

class ObjectsDynamicTypeUsedFromConstructorOrDestructorQuery extends ObjectsDynamicTypeUsedFromConstructorOrDestructorSharedQuery
{
  ObjectsDynamicTypeUsedFromConstructorOrDestructorQuery() {
    this = ImportMisra23Package::objectsDynamicTypeUsedFromConstructorOrDestructorQuery()
  }
}
