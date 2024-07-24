/**
 * @id cpp/misra/initialize-all-virtual-base-classes
 * @name RULE-15-1-2: All constructors of a class should explicitly initialize all of its virtual base classes and
 * @description All constructors of a class should explicitly initialize all of its virtual base
 *              classes and immediate base classes.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-15-1-2
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.initializeallvirtualbaseclasses.InitializeAllVirtualBaseClasses

class InitializeAllVirtualBaseClassesQuery extends InitializeAllVirtualBaseClassesSharedQuery
{
  InitializeAllVirtualBaseClassesQuery() {
    this = ImportMisra23Package::initializeAllVirtualBaseClassesQuery()
  }
}
