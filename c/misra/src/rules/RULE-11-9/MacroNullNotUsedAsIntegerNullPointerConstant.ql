/**
 * @id c/misra/macro-null-not-used-as-integer-null-pointer-constant
 * @name RULE-11-9: The macro NULL shall be the only permitted form of integer null pointer constant
 * @description The macro NULL unambiguously signifies the intended use of a null pointer constant.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-9
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.types.Pointers
import codingstandards.cpp.Type

from Zero zero, Expr e, string type
where
  not isExcluded(zero, Pointers1Package::macroNullNotUsedAsIntegerNullPointerConstantQuery()) and
  // Exclude the base-case (NULL macros and void pointer casts)
  // Note: we cannot use the isNullPointerConstant predicate here because it permits
  //       the use of `0` without casting, which is prohibited here.
  not (
    zero.findRootCause() instanceof NullMacro
    or
    // integer constant `0` explicitly cast to void pointer
    exists(Conversion c | c = zero.getConversion() |
      not c.isImplicit() and
      c.getUnderlyingType() instanceof VoidPointerType
    )
  ) and
  (
    // ?: operator
    exists(ConditionalExpr parent |
      (
        parent.getThen() = zero and parent.getElse().getType() instanceof PointerType
        or
        parent.getElse() = zero and parent.getThen().getType() instanceof PointerType
      ) and
      // exclude a common conditional pattern used in macros such as 'assert'
      not parent.isInMacroExpansion() and
      e = parent and
      type = "Ternary operator"
    )
    or
    // == or != operator
    exists(EqualityOperation op |
      op.getAnOperand() = zero and
      op.getAnOperand().getType() instanceof PointerType and
      e = op and
      type = "Equality operator"
    )
    or
    // assignment to a pointer
    exists(AssignExpr expr |
      expr.getLValue().getType() instanceof PointerType and
      expr.getRValue() = zero and
      e = expr and
      type = "Assignment to pointer"
    )
  )
select zero, "$@ uses zero-value integer constant expression as null pointer constant.", e, type
