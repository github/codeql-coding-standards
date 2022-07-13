/**
 * @id cpp/autosar/enumerations-not-declared-as-scoped-enum-classes
 * @name A7-2-3: Enumerations shall be declared as scoped enum classes
 * @description If unscoped enumeration enum is declared in a global scope, then its values can
 *              redeclare constants declared with the same identifier in the global scope. This may
 *              lead to developer’s confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-2-3
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Enum e
where
  not isExcluded(e, DeclarationsPackage::enumerationsNotDeclaredAsScopedEnumClassesQuery()) and
  not e instanceof ScopedEnum
select e, "Enum " + e.getName() + " is not a scoped enum."
