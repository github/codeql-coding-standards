/**
 * @id cpp/misra/use-of-deprecated-function-binder-typedef-member
 * @name RULE-4-1-2: Certain members of function binder typedefs are deprecated language features and should not be used
 * @description Deprecated language features such as certain function binder typedef members are
 *              only supported for backwards compatibility; these are considered bad practice, or
 *              have been superseded by better alternatives.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1-2
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.StdNamespace

predicate isFunctionTypeName(string s) {
  s =
    [
      "owner_less", "reference_wrapper", "plus", "minus", "multiplies", "divides", "modulus",
      "negate", "equal_to", "not_equal_to", "greater", "less", "greater_equal", "less_equal",
      "logical_and", "logical_or", "logical_not", "bit_and", "bit_or", "bit_xor", "bit_not",
      "function", "hash"
    ]
}

abstract class FunctionTypeWithBindings extends ClassTemplateInstantiation { }

class FunctionTypeWithBindingsByName extends FunctionTypeWithBindings {
  FunctionTypeWithBindingsByName() {
    isFunctionTypeName(getSimpleName()) and
    this.getNamespace() instanceof StdNS
  }
}

class FunctionTypeByReturnFromFunction extends FunctionTypeWithBindings {
  Function causalType;

  FunctionTypeByReturnFromFunction() {
    causalType.hasQualifiedName("std", ["bind", "mem_fn"]) and
    // The return types of std::bind and std::mem_fn are function wrapper types.
    this = causalType.getType()
  }
}

class FunctionTypeByNestedClass extends FunctionTypeWithBindings {
  Class causalType;

  FunctionTypeByNestedClass() {
    causalType.getSimpleName() = ["map", "multimap"] and
    causalType.getNamespace() instanceof StdNS and
    this.(Class).getDeclaringType() = causalType and
    this.getName() = "value_compare"
  }
}

class DeprecatedFunctionBinderTypedefMember extends UsingAliasTypedefType {
  ClassTemplateInstantiation cti;

  DeprecatedFunctionBinderTypedefMember() {
    this.getName() = ["result_type", "argument_type", "first_argument_type", "second_argument_type"] and
    this.getDeclaringType() instanceof FunctionTypeWithBindings
  }
}

from TypeMention tm, DeprecatedFunctionBinderTypedefMember member
where
  not isExcluded(tm, Toolchain3Package::useOfDeprecatedFunctionBinderTypedefMemberQuery()) and
  tm.getMentionedType() = member
select tm, "Use of deprecated function binder typedef member " + member.toString() + "."
