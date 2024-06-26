/**
 * @id cpp/misra/noexcept-function-should-not-propagate-to-the-caller
 * @name RULE-18-5-1: A noexcept function should not attempt to propagate an exception to the calling function
 * @description A noexcept function should not attempt to propagate an exception to the calling
 *              function.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-5-1
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.noexceptfunctionshouldnotpropagatetothecaller_shared.NoexceptFunctionShouldNotPropagateToTheCaller_shared

class NoexceptFunctionShouldNotPropagateToTheCallerQuery extends NoexceptFunctionShouldNotPropagateToTheCaller_sharedSharedQuery
{
  NoexceptFunctionShouldNotPropagateToTheCallerQuery() {
    this = ImportMisra23Package::noexceptFunctionShouldNotPropagateToTheCallerQuery()
  }
}
