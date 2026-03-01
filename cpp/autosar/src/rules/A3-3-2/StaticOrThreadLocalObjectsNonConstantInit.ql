/**
 * @id cpp/autosar/static-or-thread-local-objects-non-constant-init
 * @name A3-3-2: Static and thread-local objects shall be constant-initialized
 * @description Non-const global and static variables are difficult to read and maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-3-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.orderofevaluation.Initialization

from StaticStorageDurationVariable staticOrThreadLocalVar, string reason, Element reasonElement
where
  not isExcluded(staticOrThreadLocalVar,
    InitializationPackage::staticOrThreadLocalObjectsNonConstantInitQuery()) and
  isNotConstantInitialized(staticOrThreadLocalVar, reason, reasonElement) and
  // Uninstantiated templates may have initializers that are not semantically complete
  not staticOrThreadLocalVar.isFromUninstantiatedTemplate(_)
select staticOrThreadLocalVar.getInitializer(),
  "Static or thread-local object " + staticOrThreadLocalVar.getName() +
    " is not constant initialized because it $@.", reasonElement, reason
