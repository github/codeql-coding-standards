/**
 * @id cpp/autosar/operations-assuming-memory-layout-performed-on-objects
 * @name A12-0-2: Bitwise operations and operations that assume data representation in memory shall not be performed on objects
 * @description Performing bitwise operations on objects may access bits that are not part of the
 *              value representation, which may lead to undefined behavior. Operations on objects
 *              (e.g. initialization, copying, comparing, setting, accessing) shall be done by
 *              dedicated constructors, overloaded operators, accessors or mutators.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a12-0-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class Object extends Class {
  Object() { not this.(Struct).isPod() }
}

predicate isPointerToObject(Expr e) {
  e.(VariableAccess).getType().(PointerType).getBaseType() instanceof Object
  or
  e.(AddressOfExpr).getOperand().getType() instanceof Object
}

from FunctionCall fc, string functionName
where
  not isExcluded(fc, ExpressionsPackage::operationsAssumingMemoryLayoutPerformedOnObjectsQuery()) and
  /*
   * Note: this list was arbitrarily chosen, based on <https://en.cppreference.com/w/c/string/byte>,
   * and may be incomplete.
   */

  functionName in [
      "memcmp", "memset", "memset_s", "memcpy", "memcpy_s", "memmove", "memmove_s", "free"
    ] and
  fc.getTarget().hasGlobalOrStdName(functionName) and
  isPointerToObject(fc.getAnArgument())
select fc, "Use of an object as argument to 'std::" + functionName + "'."
