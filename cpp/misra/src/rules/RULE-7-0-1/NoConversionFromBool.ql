/**
 * @id cpp/misra/no-conversion-from-bool
 * @name RULE-7-0-1: There shall be no conversion from type bool
 * @description Converting a bool type (implicitly or explicitly) to another type can lead to
 *              unintended behavior and code obfuscation, particularly when using bitwise operators
 *              instead of logical operators.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-0-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.misra.BuiltInTypeRules

from Expr e, Conversion conv
where
  not isExcluded(e, ConversionsPackage::noConversionFromBoolQuery()) and
  conv = e.getConversion() and
  conv.getExpr().getType().stripTopLevelSpecifiers() instanceof BoolType and
  not conv.getType().stripTopLevelSpecifiers() instanceof BoolType and
  // Exclude cases that are explicitly allowed
  not (
    // Exception: equality operators with both bool operands
    exists(EqualityOperation eq |
      eq.getAnOperand() = e and
      eq.getLeftOperand().getType().stripTopLevelSpecifiers() instanceof BoolType and
      eq.getRightOperand().getType().stripTopLevelSpecifiers() instanceof BoolType
    )
    or
    // Exception: assignment to bit-field of length 1
    MisraCpp23BuiltInTypes::isAssignedToBitfield(e, _)
    // Note: conversions that result in a constructor call are not represented as `Conversion`s
    //       in our model, so do not need to be excluded here.
  )
select e, "Conversion from 'bool' to '" + conv.getType() + "'."
