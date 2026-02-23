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
import codingstandards.cpp.UnintializedMemoryAllocation
import codingstandards.cpp.allocations.CustomOperatorNewDelete

class AdvancedMemoryManagementFunction extends Function {
  string description;

  AdvancedMemoryManagementFunction() {
    this instanceof NonStandardNewOrNewArrayOperator and
    description = "a non-replaceable allocation function as operator `new` / `new[]`"
    or
    this instanceof NonStandardDeleteOrDeleteArrayOperator and
    description = "a non-replaceable deallocation function as operator `delete` / `delete[]`"
    or
    this instanceof UninitializedMemoryManagementFunction and
    description = "a function from <memory> that manages uninitialized memory"
  }

  string describe() { result = description }
}

class NonStandardNewOrNewArrayOperator extends CustomOperatorNewOrDelete {
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
    (
      this.getName() in ["operator new", "operator new[]"] or
      this.getName() in ["operator delete", "operator delete[]"]
    )
  }
}

class NonStandardDeleteOrDeleteArrayOperator extends CustomOperatorNewOrDelete {
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
      "This expression is a call to `" + advancedMemoryManagementFunction.getName() + "` which is " +
        advancedMemoryManagementFunction.describe() + "."
    or
    /* 2. The element takes address of the advanced memory management functions. */
    element = advancedMemoryManagementFunction.getAnAccess() and
    message =
      "This expression takes address of `" + advancedMemoryManagementFunction.getName() +
        "` which is " + advancedMemoryManagementFunction.describe() + "."
  )
  or
  (
    element instanceof VacuousDestructorCall or
    element instanceof ExplicitDestructorCall
  ) and
  message = "This expression is a call to a destructor."
  or
  element instanceof UserDeclaredOperatorNewOrDelete and
  message = "This is a user-provided declaration of `new` / `new[]` / `delete` / `delete[]`."
select element, message
