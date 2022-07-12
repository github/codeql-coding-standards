/**
 * @id cpp/autosar/unrecoverable-checked-exceptions
 * @name A15-0-5: Checked exceptions shall be used to represent errors from which the caller can reasonably be expected to recover
 * @description Checked exceptions are visible as part of the API for a function call, so should
 *              only be used for exceptions that the caller should be reasonably expected to recover
 *              from.
 * @kind problem
 * @precision low
 * @problem.severity recommendation
 * @tags external/autosar/id/a15-0-5
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

from CheckedException ce
where not isExcluded(ce, Exceptions1Package::unrecoverableCheckedExceptionsQuery())
select ce,
  "[AUDIT] Confirm checked exception is used to represent an error from which the caller can reasonable be expected to recover."
