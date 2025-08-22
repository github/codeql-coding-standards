/**
 * @id cpp/misra/function-pointer-conversion-context
 * @name RULE-7-11-3: A conversion from function type to pointer-to-function type shall only occur in appropriate contexts
 * @description Converting a function type to a pointer-to-function type outside of static_cast or
 *              assignment to a pointer-to-function object creates ambiguous behavior and potential
 *              unintended effects.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-11-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.misra.BuiltInTypeRules
import codingstandards.cpp.Type

/**
 * An `Expr` representing an implicit conversion from a function type to a pointer-to-function type.
 *
 * Despite the name, these are not `Conversion`s in our model. Instead, they are expressions
 * representing functions that have been implicilty converted to function pointers.
 */
abstract class FunctionToFunctionPointerConversion extends Expr { }

/**
 * A `FunctionAccess` that has been implicitly converted to a function pointer type.
 */
class FunctionAccessConversionToFunctionPointer extends FunctionAccess,
  FunctionToFunctionPointerConversion
{
  FunctionAccessConversionToFunctionPointer() {
    this.getType().getUnspecifiedType() instanceof FunctionPointerIshType
  }
}

/**
 * A `Call` to a `ConversionOperator` that converts a lambda to a function pointer type.
 */
class LambdaFunctionPointerConversion extends Call, FunctionToFunctionPointerConversion {
  LambdaFunctionPointerConversion() {
    this.getTarget().(ConversionOperator).getDestType() instanceof FunctionPointerIshType and
    this.getQualifier().getType().getUnspecifiedType() instanceof Closure
  }
}

from FunctionToFunctionPointerConversion f
where
  not isExcluded(f, ConversionsPackage::functionPointerConversionContextQuery()) and
  // Not converted by an explicit static cast
  not exists(Conversion c |
    c.getExpr() = f and
    not c.isImplicit() and
    c.getType().getUnspecifiedType() instanceof FunctionPointerIshType
  ) and
  // Not a MISRA compliant assignment to a function pointer type
  not exists(FunctionPointerIshType targetType |
    MisraCpp23BuiltInTypes::isAssignment(f, targetType, _)
  )
select f,
  "Inappropriate conversion from function type to pointer-to-function type in '" + f.toString() +
    "'."
