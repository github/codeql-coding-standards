/**
 * @id cpp/autosar/function-return-multiple-value-condition
 * @name A8-4-4: Multiple output values from a function should be returned as a struct or tuple
 * @description Multiple output values from functions that do not return as struct or tuple can
 *              cause confusion an add overhead for compilers.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a8-4-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow

abstract class OutputValue extends Element {
  abstract string getOutputName();
}

class ModifiedOutputParameter extends Parameter, OutputValue {
  ModifiedOutputParameter() {
    (
      this.getUnderlyingType() instanceof ReferenceType
      or
      this.getUnderlyingType() instanceof PointerType
    ) and
    // A parameter is a modified out parameter if it is directly assigned to
    exists(getAnAssignment())
  }

  override string getOutputName() { result = "out parameter " + getName() }
}

class FunctionReturnValue extends OutputValue, Function {
  FunctionReturnValue() { not getType() instanceof VoidType }

  override string getOutputName() { result = "return type " + getType().getName() }
}

OutputValue getAnOutputValue(Function f) {
  result = f
  or
  result = f.getAParameter()
}

from Function f, int outputValues
where
  not isExcluded(f, FunctionsPackage::functionReturnMultipleValueConditionQuery()) and
  not f.isCompilerGenerated() and
  not f.isAffectedByMacro() and
  not f.isFromUninstantiatedTemplate(_) and
  not f instanceof Operator and
  outputValues = count(getAnOutputValue(f)) and
  outputValues > 1
select f,
  "Function " + f.getQualifiedName() + " outputs " + outputValues + " separate values (" +
    concat(OutputValue v | v = getAnOutputValue(f) | v.getOutputName(), ", ") + ")."
