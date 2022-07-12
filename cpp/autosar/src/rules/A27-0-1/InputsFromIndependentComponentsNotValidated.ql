/**
 * @id cpp/autosar/inputs-from-independent-components-not-validated
 * @name A27-0-1: Inputs from independent components shall be validated
 * @description Inputs from independent components is not validated.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a27-0-1
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.nonconstantformat.NonConstantFormat

class InputsFromIndependentComponentsNotValidatedQuery extends NonConstantFormatSharedQuery {
  InputsFromIndependentComponentsNotValidatedQuery() {
    this = TypeRangesPackage::inputsFromIndependentComponentsNotValidatedQuery()
  }
}
