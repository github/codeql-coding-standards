/**
 * @id c/misra/memcmp-on-inappropriate-essential-type-args
 * @name RULE-21-16: Do not use memcmp on pointers to characters or composite types such as structs and unions
 * @description The pointer arguments to the Standard Library function memcmp shall point to either
 *              a pointer type, an essentially signed type, an essentially unsigned type, an
 *              essentially Boolean type or an essentially enum type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-16
 *       maintainability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes

from FunctionCall memcmp, Expr arg, Type argBaseType
where
  not isExcluded(arg, EssentialTypesPackage::memcmpOnInappropriateEssentialTypeArgsQuery()) and
  memcmp.getTarget().hasGlobalOrStdName("memcmp") and
  // Pointer arguments
  arg = memcmp.getArgument([0, 1]) and
  exists(DerivedType pt |
    // Must be a pointer type or array type
    (
      pt instanceof PointerType or
      pt instanceof ArrayType
    ) and
    pt = arg.getType() and
    argBaseType = pt.getBaseType() and
    // Doesn't point to a pointer type
    not argBaseType instanceof PointerType and
    // Doesn't point to a type which is essentially signed, unsigned, boolean or enum
    not exists(EssentialTypeCategory typeCategory |
      typeCategory = getEssentialTypeCategory(argBaseType)
    |
      typeCategory = EssentiallySignedType() or
      typeCategory = EssentiallyUnsignedType() or
      typeCategory = EssentiallyBooleanType() or
      typeCategory = EssentiallyEnumType()
    )
  )
select arg, "Argument is a pointer to " + argBaseType + "."
