/**
 * @id cpp/autosar/no-except-function-throws
 * @name A15-4-2: A function declared to be noexcept(true) shall not exit with an exception
 * @description If a function is declared to be noexcept, noexcept(true) or noexcept(<true
 *              condition>), then it shall not exit with an exception.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a15-4-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.noexceptfunctionshouldnotpropagatetothecaller_shared.NoexceptFunctionShouldNotPropagateToTheCaller_shared

class NoExceptFunctionThrowsQuery extends NoexceptFunctionShouldNotPropagateToTheCaller_sharedSharedQuery {
  NoExceptFunctionThrowsQuery() {
    this = Exceptions1Package::noExceptFunctionThrowsQuery()
  }
}
