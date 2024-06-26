/**
 * @id cpp/autosar/recursive-functions
 * @name A7-5-2: Functions shall not call themselves, either directly or indirectly
 * @description Using recursive functions can lead to stack overflows and limit scalability and
 *              portability of the program.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-5-2
 *       correctness
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.functionscallthemselveseitherdirectlyorindirectly_shared.FunctionsCallThemselvesEitherDirectlyOrIndirectly_shared

class RecursiveFunctionsQuery extends FunctionsCallThemselvesEitherDirectlyOrIndirectly_sharedSharedQuery {
  RecursiveFunctionsQuery() {
    this = FunctionsPackage::recursiveFunctionsQuery()
  }
}
