/**
 * @id cpp/autosar/missed-nsdmi-opportunity
 * @name A12-1-3: Use non-static data member initialization to initialize constant data members
 * @description If all user-defined constructors of a class initialize data members with constant
 *              values that are the same across all constructors, then data members shall be
 *              initialized using non-static data member initialization instead.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-1-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

Field getAnInitializableField(Class c) {
  exists(Field directField | directField = c.getAField() |
    result = directField
    or
    directField.getType() instanceof Union and
    result = getAnInitializableField(directField.getType())
  )
}

from Field f, Class declaringClass, string value, ConstructorFieldInit initalizer
where
  not isExcluded(f, InitializationPackage::missedNSDMIOpportunityQuery()) and
  f = getAnInitializableField(declaringClass) and
  // All user-defined constructors have a `ConstructorFieldInit`, which is set to the same literal value
  // We use forex because the user must have written at least one constructor for this to be a valid result
  forex(Constructor constructor |
    constructor = declaringClass.getAConstructor() and
    // Ignore compiler generated constructors
    not constructor.isCompilerGenerated()
  |
    exists(ConstructorFieldInit cfi |
      // ConstructorFieldInit associated with this constructor
      constructor.getAnInitializer() = cfi and
      // Not compiler generated
      not cfi.isCompilerGenerated() and
      // Targets the field
      cfi.getTarget() = f and
      // And has the same constant value in each CFI
      value = cfi.getExpr().getValue()
    )
  ) and
  // Find the initializers with the constant values
  initalizer.getTarget() = f and
  not initalizer.isCompilerGenerated() and
  not initalizer.getEnclosingFunction().isCompilerGenerated()
select f,
  "Field " + declaringClass.getSimpleName() + "::" + f.getName() + " is explicitly set to " + value +
    " in all $@ instead of using non-static data member initialization.", initalizer, "constructors"
