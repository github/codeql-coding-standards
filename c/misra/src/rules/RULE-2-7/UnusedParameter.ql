/**
 * @id c/misra/unused-parameter
 * @name RULE-2-7: There should be no unused parameters in functions
 * @description Unused parameters can indicate a mistake when implementing the function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-2-7
 *       readability
 *       maintainability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.unusedparameter.UnusedParameter

class UnusedParameterQuery extends UnusedParameterSharedQuery {
  UnusedParameterQuery() {
    this = DeadCodePackage::unusedParameterQuery()
  }
}
