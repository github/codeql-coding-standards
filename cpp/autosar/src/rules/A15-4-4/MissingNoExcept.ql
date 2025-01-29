/**
 * @id cpp/autosar/missing-no-except
 * @name A15-4-4: A declaration of non-throwing function shall contain noexcept specification
 * @description Adding a noexcept specifier makes it clearer that the function is not intended to
 *              throw functions.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a15-4-4
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionSpecifications
import codingstandards.cpp.exceptions.ExceptionFlow

// These functions have a noexcept specification that could not be resolved
// to noexcept(true). So either, they are noexcept(false) functions which
// means, they can throw an exception OR they have an expression which
// could not be resolved to "true" or "false". Even in this case, lets
// be more conservative and assume they may thrown an exception.
class FunctionWithUnknownNoExcept extends Function {
  FunctionWithUnknownNoExcept() {
    // Exists a noexcept specification but not noexcept(true)
    exists(this.getADeclarationEntry().getNoExceptExpr()) and
    not isNoExceptTrue(this)
  }
}

// This predicate checks if a function can call to other functions
// that may have a noexcept specification which cannot be resolved to
// noexcept(true).
predicate mayCallThrowingFunctions(Function f) {
  // Exists a call in this function
  exists(Call fc |
    fc.getEnclosingFunction() = f and
    (
      // Either this call is to a function with an unknown noexcept OR
      fc.getTarget() instanceof FunctionWithUnknownNoExcept
      or
      // That function can further have calls to unknown noexcept functions.
      mayCallThrowingFunctions(fc.getTarget())
    )
  )
}

from Function f
where
  not isExcluded(f.getADeclarationEntry(), Exceptions1Package::missingNoExceptQuery()) and
  // No thrown exceptions
  not exists(getAFunctionThrownType(f, _)) and
  // But not marked noexcept(true)
  not isNoExceptTrue(f) and
  // Not explicitly marked noexcept(false)
  not isNoExceptExplicitlyFalse(f) and
  // Not having a noexcept specification that
  // could not be computed as true or false above.
  not exists(f.getADeclarationEntry().getNoExceptExpr()) and
  // Not calling function(s) which have a noexcept specification that
  // could not be computed as true.
  not mayCallThrowingFunctions(f) and
  // Not compiler generated
  not f.isCompilerGenerated() and
  // The function is defined in this database
  f.hasDefinition() and
  // This function is not an overriden call operator of a lambda expression
  not exists(LambdaExpression lambda | lambda.getLambdaFunction() = f) and
  // Exclude results from uinstantiated templates
  not f.isFromUninstantiatedTemplate(_)
select f, "Function " + f.getQualifiedName() + " could be declared noexcept(true)."
