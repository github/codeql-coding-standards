/**
 * @id cpp/autosar/unused-local-function
 * @name A0-1-3: Unused local function
 * @description Every function defined in an anonymous namespace, or static function with internal
 *              linkage, or private member function shall be used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.unusedlocalfunction.UnusedLocalFunction

module UnusedLocalFunctionConfig implements UnusedLocalFunctionConfigSig {
  Query getQuery() { result = DeadCodePackage::unusedLocalFunctionQuery() }
}

import UnusedLocalFunction<UnusedLocalFunctionConfig>
