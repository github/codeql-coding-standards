/**
 * @id cpp/autosar/reinterpret-cast-used
 * @name A5-2-4: reinterpret_cast shall not be used
 * @description The statement reinterpret_cast shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-2-4
 *       correctness
 *       security
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.reinterpretcastused_shared.ReinterpretCastUsed_shared

class ReinterpretCastUsedQuery extends ReinterpretCastUsed_sharedSharedQuery {
  ReinterpretCastUsedQuery() { this = BannedSyntaxPackage::reinterpretCastUsedQuery() }
}
