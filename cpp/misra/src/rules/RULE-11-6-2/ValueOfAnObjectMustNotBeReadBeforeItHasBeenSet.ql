/**
 * @id cpp/misra/value-of-an-object-must-not-be-read-before-it-has-been-set
 * @name RULE-11-6-2: The value of an object must not be read before it has been set
 * @description Reading from uninitialized indeterminate values may produce undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-11-6-2
 *       correctness
 *       security
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.readofuninitializedmemory.ReadOfUninitializedMemory

class ValueOfAnObjectMustNotBeReadBeforeItHasBeenSetQuery extends ReadOfUninitializedMemorySharedQuery {
  ValueOfAnObjectMustNotBeReadBeforeItHasBeenSetQuery() {
    this = LifetimePackage::valueOfAnObjectMustNotBeReadBeforeItHasBeenSetQuery()
  }
}
