/**
 * @id cpp/misra/advanced-memory-management-used
 * @name RULE-21-6-3: Advanced memory management shall not be used
 * @description Using advanced memory management that either alters allocation and deallocation or
 *              constructs object construction on uninitalized memory may result in undefined
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-6-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.standardlibrary.Memory
import codingstandards.cpp.allocations.CustomOperatorNewDelete

class AdvancedMemoryManagementFunction extends Function {
  string description;

  AdvancedMemoryManagementFunction() {
    this instanceof NonStandardNewOrNewArrayOperator and
    description = "a non-replaceable allocation function"
    or
    this instanceof NonStandardDeleteOrDeleteArrayOperator and
    description = "a non-replaceable deallocation function"
    or
    this instanceof UninitializedMemoryManagementFunction and
    description = "a function from <memory> that manages uninitialized memory"
  }

  string describe() { result = description }
}

class NonStandardNewOrNewArrayOperator extends OperatorNewOrDelete {
  NonStandardNewOrNewArrayOperator() {
    this.getName() in ["operator new", "operator new[]"] and
    not this instanceof CustomOperatorNew // `CustomOperatorNew` only detects replaceable allocation functions.
  }
}

/**
 * A user-provided declaration of `new` / `new[]` / `delete` / `delete[]`.
 *
 * NOTE: Technically, the rule does not care if the declarations are in user-provided code,
 * but for the sake of development, we want to exclude the stubs we index into the database.
 */
class UserDeclaredOperatorNewOrDelete extends FunctionDeclarationEntry {
  UserDeclaredOperatorNewOrDelete() {
    /* Not in the standard library */
    exists(this.getFile().getRelativePath()) and
    /* Not in a file called `new`, which is likely to be a stub of the standard library */
    not this.getFile().getBaseName() = "new" and
    this.getFunction() instanceof OperatorNewOrDelete
  }
}

class NonStandardDeleteOrDeleteArrayOperator extends OperatorNewOrDelete {
  NonStandardDeleteOrDeleteArrayOperator() {
    this.getName() in ["operator delete", "operator delete[]"] and
    not this instanceof CustomOperatorDelete // `CustomOperatorDelete` only detects replaceable deallocation functions.
  }
}

class ExplicitDestructorCall extends DestructorCall {
  ExplicitDestructorCall() { not this.isCompilerGenerated() }
}

from Element element, string message
where
  not isExcluded(element, Memory6Package::advancedMemoryManagementUsedQuery()) and
  exists(AdvancedMemoryManagementFunction advancedMemoryManagementFunction |
    /* 1. The element is a call to one of the advanced management functions. */
    element = advancedMemoryManagementFunction.getACallToThisFunction() and
    message =
      "Call to banned function `" + advancedMemoryManagementFunction.getName() +
        //"."
        "` which is " + advancedMemoryManagementFunction.describe() + "."
    or
    /* 2. The element takes address of the advanced memory management functions. */
    element = advancedMemoryManagementFunction.getAnAccess() and
    message =
      "Taking the address of a banned function `" + advancedMemoryManagementFunction.getName() +
        "` which is " + advancedMemoryManagementFunction.describe() + "."
    //  "`."
  )
  or
  (
    element instanceof VacuousDestructorCall or
    element instanceof ExplicitDestructorCall
  ) and
  message = "Manual call to a destructor."
  or
  element instanceof UserDeclaredOperatorNewOrDelete and
  message =
    "User-provided declaration of `" +
      element.(UserDeclaredOperatorNewOrDelete).getFunction().getName() + "`."
select element, message
