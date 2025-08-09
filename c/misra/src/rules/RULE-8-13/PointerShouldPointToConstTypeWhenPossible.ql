/**
 * @id c/misra/pointer-should-point-to-const-type-when-possible
 * @name RULE-8-13: A pointer should point to a const-qualified type whenever possible
 * @description A pointer should point to a const-qualified type unless it is used to modify an
 *              object or the underlying object data is copied.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-8-13
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.types.Pointers
import codingstandards.cpp.SideEffect
import codingstandards.cpp.alertreporting.HoldsForAllCopies

class NonConstPointerVariableCandidate extends Variable {
  NonConstPointerVariableCandidate() {
    // Ignore parameters in functions without bodies
    (this instanceof Parameter implies exists(this.(Parameter).getFunction().getBlock())) and
    // Ignore variables in functions that use ASM commands
    not exists(AsmStmt a |
      a.getEnclosingFunction() = this.(LocalScopeVariable).getFunction()
      or
      // In a type declared locally
      this.(Field).getDeclaringType+().getEnclosingFunction() = a.getEnclosingFunction()
    ) and
    exists(PointerOrArrayType type |
      // include only pointers which point to a const-qualified type
      this.getType() = type and
      not type.isDeeplyConstBelow()
    ) and
    // exclude pointers passed as arguments to functions which take a
    // parameter that points to a non-const-qualified type
    not exists(FunctionCall fc, int i |
      fc.getArgument(i) = this.getAnAccess() and
      not fc.getTarget().getParameter(i).getType().isDeeplyConstBelow()
    ) and
    // exclude any pointers which have their underlying data modified
    not exists(VariableEffect effect |
      effect.getTarget() = this and
      // but not pointers that are only themselves modified
      not effect.(AssignExpr).getLValue() = this.getAnAccess() and
      not effect.(CrementOperation).getOperand() = this.getAnAccess()
    ) and
    // exclude pointers assigned to another pointer to a non-const-qualified type
    not exists(Variable a |
      a.getAnAssignedValue() = this.getAnAccess() and
      not a.getType().(PointerOrArrayType).isDeeplyConstBelow()
    )
  }
}

/**
 * Ensure that all copies of a variable are considered to be missing const qualification to avoid
 * false positives where a variable is only used/modified in a single copy.
 */
class NonConstPointerVariable =
  HoldsForAllCopies<NonConstPointerVariableCandidate, Variable>::LogicalResultElement;

from NonConstPointerVariable ptr
where
  not isExcluded(ptr.getAnElementInstance(),
    Pointers1Package::pointerShouldPointToConstTypeWhenPossibleQuery())
select ptr, "$@ points to a non-const-qualified type.", ptr, ptr.getAnElementInstance().getName()
