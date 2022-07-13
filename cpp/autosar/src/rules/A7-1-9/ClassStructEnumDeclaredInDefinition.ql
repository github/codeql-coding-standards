/**
 * @id cpp/autosar/class-struct-enum-declared-in-definition
 * @name A7-1-9: A class, structure, or enumeration shall not be declared in the definition of its type
 * @description Combining a type definition with a declaration of another entity can lead to
 *              readability problems and can be confusing for a developer.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-1-9
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

int endLineOfType(UserType c) {
  result =
    max(Location l |
      c.getADeclaration().getLocation() = l
      or
      c.(Enum).getAnEnumConstant().getLocation() = l
    |
      l.getEndLine()
    )
}

/*
 * This query makes use of location information between `UserType`s and
 * `Variable`s to account for gaps in our modeling of this scenario. The
 * logic of this query is essentially that it looks for the last definition
 * in a struct/enum/class and checks to see if there is a variable declaration
 * of that type on the following (or same) line outside the element.
 */

from UserType t, Variable v, int distance
where
  not isExcluded(t, DeclarationsPackage::classStructEnumDeclaredInDefinitionQuery()) and
  not isExcluded(v, DeclarationsPackage::classStructEnumDeclaredInDefinitionQuery()) and
  not v instanceof Parameter and
  v.getType() = t and
  // Handle issues with forward declarations
  v.getFile() = t.getFile() and
  v.getLocation().getStartLine() - endLineOfType(t) = distance and
  distance >= 0 and
  distance <= 1
select v, "Variable declared in the definition of its type $@", v, t.getName()
