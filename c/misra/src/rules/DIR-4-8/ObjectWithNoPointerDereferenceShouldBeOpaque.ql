/**
 * @id c/misra/object-with-no-pointer-dereference-should-be-opaque
 * @name DIR-4-8: The implementation of an object shall be hidden if a pointer to its structure or union is never dereferenced within a translation unit
 * @description If a pointer to a structure or union is never dereferenced within a translation
 *              unit, then the implementation of the object should be hidden to prevent
 *              unintentional changes.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/dir-4-8
 *       readability
 *       maintainability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Scope

TranslationUnit commonTranslationUnit(File a, File b) {
  result.getAUserFile() = a and
  result.getAUserFile() = b
}

from Struct base, TranslationUnit tu
where
  not isExcluded(base, Pointers1Package::objectWithNoPointerDereferenceShouldBeOpaqueQuery()) and
  // exclude cases like `struct s1;`
  base.getSize() > 0 and
  exists(Expr e |
    e.getType().(PointerType).getBaseType().stripType() = base and
    tu = commonTranslationUnit(e.getFile(), base.getFile())
  ) and
  not exists(FieldAccess fa |
    inSameTranslationUnit(fa.getFile(), base.getFile()) and
    fa.getQualifier().getType().stripType() = base
  ) and
  // exclude translation units where there exists a non-pointer variable of type `base`
  not exists(Variable v |
    v.getType().stripType() = base and
    not v.getType().getUnderlyingType() instanceof PointerType and
    inSameTranslationUnit(v.getFile(), base.getFile())
  )
select base,
  "$@ is not opaque but no pointer to it is dereferenced within the translation unit $@.", base,
  base.getName(), tu, tu.getBaseName()
