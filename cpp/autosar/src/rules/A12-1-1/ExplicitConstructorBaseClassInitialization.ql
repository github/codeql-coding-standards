/**
 * @id cpp/autosar/explicit-constructor-base-class-initialization
 * @name A12-1-1: Constructors shall explicitly initialize all base classes
 * @description Constructors shall explicitly initialize all virtual base classes, all direct
 *              non-virtual base classes and all non-static data members.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a12-1-1
 *       maintainability
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.initializeallvirtualbaseclasses.InitializeAllVirtualBaseClasses

class ExplicitConstructorBaseClassInitializationQuery extends InitializeAllVirtualBaseClassesSharedQuery
{
  ExplicitConstructorBaseClassInitializationQuery() {
    this = InitializationPackage::explicitConstructorBaseClassInitializationQuery()
  }
}
