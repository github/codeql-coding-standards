/**
 * @id cpp/autosar/recoverable-unchecked-exceptions
 * @name A15-0-4: Unchecked exceptions shall be used to represent errors from which the caller cannot reasonably be expected to recover
 * @description Unchecked exceptions are not visible as part of the API for a function call, so
 *              should not be used for exceptions that the caller should be reasonably expected to
 *              recover from.
 * @kind problem
 * @precision low
 * @problem.severity recommendation
 * @tags external/autosar/id/a15-0-4
 *       maintainability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/audit
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.autosar.CheckedException

from UncheckedException uncheckedException
where not isExcluded(uncheckedException, Exceptions1Package::recoverableUncheckedExceptionsQuery())
select uncheckedException,
  "[AUDIT] Confirm unchecked exception is used to represent an error from which the caller cannot be reasonable expected to recover."
