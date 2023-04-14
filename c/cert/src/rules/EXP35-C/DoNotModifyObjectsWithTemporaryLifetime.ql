/**
 * @id c/cert/do-not-modify-objects-with-temporary-lifetime
 * @name EXP35-C: Do not modify objects with temporary lifetime
 * @description Attempting to modify an object with temporary lifetime results in undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp35-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/**
 * A struct or union type that contains an array type
 */
class StructOrUnionTypeWithArrayField extends Struct {
  StructOrUnionTypeWithArrayField() {
    this.getAField().getUnspecifiedType() instanceof ArrayType
    or
    // nested struct or union containing an array type
    this.getAField().getUnspecifiedType().(Struct) instanceof StructOrUnionTypeWithArrayField
  }
}

// Note: Undefined behavior is possible regardless of whether the accessed field from the returned
// struct is an array or a scalar (i.e. arithmetic and pointer types) member, according to the standard.
from FieldAccess fa, FunctionCall fc
where
  not isExcluded(fa, InvalidMemory2Package::doNotModifyObjectsWithTemporaryLifetimeQuery()) and
  not fa.getQualifier().isLValue() and
  fa.getQualifier().getUnconverted() = fc and
  fa.getQualifier().getUnconverted().getUnspecifiedType() instanceof StructOrUnionTypeWithArrayField
select fa, "Field access on $@ qualifier occurs after its temporary object lifetime.", fc,
  "function call"
