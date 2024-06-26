/**
 * @id cpp/autosar/missing-u-suffix
 * @name M2-13-3: A 'U' suffix shall be applied to all octal or hexadecimal integer literals of unsigned type
 * @description Use a 'U' suffix to ensure all unsigned literals have a consistent signedness across
 *              platforms and compilers.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m2-13-3
 *       correctness
 *       readability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.unsignedintegerliteralsnotappropriatelysuffixed_shared.UnsignedIntegerLiteralsNotAppropriatelySuffixed_shared

class MissingUSuffixQuery extends UnsignedIntegerLiteralsNotAppropriatelySuffixed_sharedSharedQuery {
  MissingUSuffixQuery() {
    this = LiteralsPackage::missingUSuffixQuery()
  }
}
