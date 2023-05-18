/**
 * @id cpp/autosar/class-type-exception-not-caught-by-reference
 * @name A15-3-5: A class type exception shall be caught by reference or const reference
 * @description A non-trivial class type exception which is not caught by lvalue reference may be
 *              sliced, losing valuable exception information.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a15-3-5
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.catchexceptionsbylvaluereference.CatchExceptionsByLvalueReference

class ClassTypeExceptionNotCaughtByReference extends CatchExceptionsByLvalueReferenceSharedQuery {
  ClassTypeExceptionNotCaughtByReference() {
    this = Exceptions2Package::classTypeExceptionNotCaughtByReferenceQuery()
  }
}
