/**
 * @id c/misra/pointer-to-a-file-object-dereferenced
 * @name RULE-22-5: A pointer to a FILE object shall not be dereferenced
 * @description A FILE object should not be directly manipulated.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-5
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra

class IndirectlyDereferencedExpr extends Expr {
  IndirectlyDereferencedExpr() {
    exists(Call call, string names |
      names = ["memcmp", "memcpy"] and
      (
        call.getTarget().hasGlobalOrStdName(names)
        or
        exists(MacroInvocation mi | mi.getMacroName() = names and call = mi.getExpr())
      ) and
      this = [call.getArgument(0), call.getArgument(1)]
    )
  }
}

from Expr e
where
  not isExcluded(e, IO3Package::pointerToAFileObjectDereferencedQuery()) and
  (
    e.(PointerDereferenceExpr).getType().hasName("FILE") or
    e.(PointerFieldAccess).getQualifier().getType().(DerivedType).getBaseType().hasName("FILE") or
    e.(IndirectlyDereferencedExpr).getType().(DerivedType).getBaseType().hasName("FILE")
  )
select e, "Dereferencing an object of type `FILE`."
