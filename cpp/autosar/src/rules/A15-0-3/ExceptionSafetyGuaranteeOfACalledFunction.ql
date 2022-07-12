/**
 * @id cpp/autosar/exception-safety-guarantee-of-a-called-function
 * @name A15-0-3: Consider exception safety guarantee of called functions
 * @description Exception safety guarantee of a called function shall be considered.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a15-0-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.UnhandledExceptions
import codingstandards.cpp.exceptions.ExceptionSpecifications

/*
 * The query flags move and copy constructors that might throw an exception when inserting
 * elements in a container using one of the standard library functions that do not guarantee
 * complete exception safety.
 * It does not further distinguish beween copy-insertable and non-copy-insertable types
 * but it is nonetheless precise enough in practice.
 */

/**
 * `ExceptionUnsafeFunctionCall` models function calls that might show unexpected behavior
 * due to exceptions thrown by the constructors of used types
 */
abstract class ExceptionUnsafeFunctionCall extends FunctionCall {
  Type specialization;

  Type getSpecialization() { result = specialization }
}

class VectorExceptionUnsafeFunctionCall extends ExceptionUnsafeFunctionCall {
  VectorExceptionUnsafeFunctionCall() {
    getTarget()
        .hasQualifiedName("std", "vector", ["insert", "emplace_back", "emplace", "push_back"]) and
    specialization = getTarget().getDeclaringType().getTemplateArgument(0) and
    (
      // call to insert or emplace
      getTarget().hasName(["insert", "emplace"]) and
      not (
        //not inserting a single element
        getTarget().getNumberOfParameters() <= 2 and
        not getTarget().getParameter(1).getType().getName().matches("initializer_list%") and
        // not inserting at the end
        getArgument(0).(FunctionCall).getTarget().getName() = "end"
        or
        getArgument(0).(ConstructorCall).getArgument(0).(FunctionCall).getTarget().getName() = "end"
        //TODO: not (t is copy insertable or is_nothrow_move_constructible<T>::value is true)
      )
      or
      // move constructor of T
      getTarget() instanceof MoveConstructor
    )
  }
}

class DequeExceptionUnsafeFunctionCall extends ExceptionUnsafeFunctionCall {
  DequeExceptionUnsafeFunctionCall() {
    getTarget()
        .hasQualifiedName("std", "deque",
          ["insert", "emplace_front", "emplace_back", "emplace", "push_front", "push_back"]) and
    specialization = getTarget().getDeclaringType().getTemplateArgument(0) and
    (
      // call to insert or emplace
      getTarget().hasName(["insert", "emplace"]) and
      not (
        //not inserting a single element
        getTarget().getNumberOfParameters() <= 2 and
        not getTarget().getParameter(1).getType().getName().matches("initializer_list%") and
        // not inserting at the begin or end
        getArgument(0).(FunctionCall).getTarget().getName() = ["begin", "end"]
        or
        getArgument(0).(ConstructorCall).getArgument(0).(FunctionCall).getTarget().getName() =
          ["begin", "end"]
      )
      or
      // move constructor of T
      getTarget() instanceof MoveConstructor
    )
  }
}

/**
 * `ExceptionUnsafeConstructor` models constructors that can throw an exception
 * Exception may be thrown by the copy constructor, move constructor, assignment operator,
 * or move assignment operator
 */
class ExceptionUnsafeConstructor extends Constructor {
  ExceptionUnsafeConstructor() {
    (
      this instanceof MoveConstructor or
      this instanceof CopyConstructor or
      this.hasName("operator=")
    ) and
    // not noexcept
    not isNoExceptTrue(this)
  }
}

from ExceptionUnsafeFunctionCall fc, Type t
where
  not isExcluded(fc, ExceptionSafetyPackage::exceptionSafetyGuaranteeOfACalledFunctionQuery()) and
  t = fc.getSpecialization() and
  exists(ExceptionUnsafeConstructor c | c.getDeclaringType() = t)
select fc,
  "The copy or move constructor of $@ might throw an exception when used in the call to `" +
    fc.getTarget().getName() + "`, which could leave the container in an invalid state.", t,
  t.toString()
