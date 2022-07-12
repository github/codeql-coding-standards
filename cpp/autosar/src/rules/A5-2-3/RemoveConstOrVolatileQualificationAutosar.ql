/**
 * @id cpp/autosar/remove-const-or-volatile-qualification-autosar
 * @name A5-2-3: A cast shall not remove any const or volatile qualification from the type of a pointer or reference
 * @description Removing `const`/`volatile` qualification can result in undefined behavior when a
 *              `const`/`volatile` qualified object is modified through a non-const access path.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a5-2-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.removeconstorvolatilequalification.RemoveConstOrVolatileQualification

class RemoveConstOrVolatileQualificationAutosarQuery extends RemoveConstOrVolatileQualificationSharedQuery {
  RemoveConstOrVolatileQualificationAutosarQuery() {
    this = ConstPackage::removeConstOrVolatileQualificationAutosarQuery()
  }
}
