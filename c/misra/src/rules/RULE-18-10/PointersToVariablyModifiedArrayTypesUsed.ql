/**
 * @id c/misra/pointers-to-variably-modified-array-types-used
 * @name RULE-18-10: Pointers to variably-modified array types shall not be used
 * @description Pointers to variably-modified array types shall not be used, as these pointer types
 *              are frequently incompatible with other fixed or variably sized arrays, resulting in
 *              undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-18-10
 *       external/misra/c/2012/amendment4
 *       correctness
 *       security
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.types.VariablyModifiedTypes

from VmtDeclarationEntry v, string declstr, string adjuststr, string relationstr
where
  not isExcluded(v, InvalidMemory3Package::pointersToVariablyModifiedArrayTypesUsedQuery()) and
  // Capture only pointers to VLA types, not raw VLA types.
  not v.getVlaType() = v.getType() and
  (
    if v instanceof ParameterDeclarationEntry
    then declstr = "Parameter "
    else
      if v instanceof VariableDeclarationEntry
      then declstr = "Variable "
      else declstr = "Declaration "
  ) and
  (
    if
      v instanceof ParameterDeclarationEntry and
      v.getType() instanceof ParameterAdjustedVariablyModifiedType
    then adjuststr = "adjusted to"
    else adjuststr = "declared with"
  ) and
  (
    if v.getType().(PointerType).getBaseType() instanceof CandidateVlaType
    then relationstr = "pointer to"
    else relationstr = "with inner"
  ) and
  // Remove results that appear to be unreliable, potentially from a macro.
  not v.appearsDuplicated()
select v,
  declstr + v.getName() + " is " + adjuststr + " variably-modified type, " + relationstr +
    " variable length array of non constant size $@ and element type '" +
    v.getVlaType().getVariableBaseType() + "'", v.getSizeExpr(), v.getSizeExpr().toString()
