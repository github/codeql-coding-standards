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
import codingstandards.cpp.Constructor

from Constructor c, Class declaringType, Class baseClass, string type
where
  not isExcluded(c, InitializationPackage::explicitConstructorBaseClassInitializationQuery()) and
  declaringType = c.getDeclaringType() and
  (
    declaringType.getABaseClass() = baseClass and type = ""
    or
    baseClass.(VirtualBaseClass).getAVirtuallyDerivedClass().getADerivedClass+() = declaringType and
    type = " virtual"
  ) and
  // There is not an initializer on the constructor for this particular base class
  not exists(ConstructorBaseClassInit init |
    c.getAnInitializer() = init and
    init.getInitializedClass() = baseClass and
    not init.isCompilerGenerated()
  ) and
  // Must be a defined constructor
  c.hasDefinition() and
  // Not a compiler-generated constructor
  not c.isCompilerGenerated() and
  // Not a defaulted constructor
  not c.isDefaulted()
select c, "Constructor for $@ does not explicitly call constructor for" + type + " base class $@.",
  declaringType, declaringType.getSimpleName(), baseClass, baseClass.getSimpleName()
