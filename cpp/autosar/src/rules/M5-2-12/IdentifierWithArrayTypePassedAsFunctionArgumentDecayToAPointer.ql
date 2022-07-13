/**
 * @id cpp/autosar/identifier-with-array-type-passed-as-function-argument-decay-to-a-pointer
 * @name M5-2-12: An identifier with array type passed as a function argument shall not decay to a pointer
 * @description An identifier with array type passed as a function argument shall not decay to a
 *              pointer to prevent loss of its bounds.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m5-2-12
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate arrayToPointerDecay(Access ae, Parameter p) {
  (
    p.getType() instanceof PointerType and
    // exclude parameters of void* because then it assumed the caller can pass in dimensions through other means.
    // examples are uses in `memset` or `memcpy`
    not p.getType() instanceof VoidPointerType
    or
    p.getType() instanceof ArrayType
  ) and
  ae.getType() instanceof ArrayType and
  // exclude char[] arrays because we assume that we can determine its dimension by looking for a NULL byte.
  not ae.getType().(ArrayType).getBaseType() instanceof CharType
}

from
  FunctionCall fc, Function f, Parameter decayedArray, Variable array, VariableAccess arrayAccess,
  int i
where
  not isExcluded(fc,
    PointersPackage::identifierWithArrayTypePassedAsFunctionArgumentDecayToAPointerQuery()) and
  arrayAccess = array.getAnAccess() and
  f = fc.getTarget() and
  arrayAccess = fc.getArgument(i) and
  decayedArray = f.getParameter(i) and
  arrayToPointerDecay(arrayAccess, decayedArray) and
  not arrayAccess.isAffectedByMacro()
select fc.getArgument(i),
  "The array $@ decays to the pointer $@ when passed as an argument to the function $@.", array,
  array.getName(), decayedArray, decayedArray.getName(), f, f.getName()
