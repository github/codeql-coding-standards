/**
 * @id cpp/misra/pointer-or-ref-param-not-const
 * @name RULE-10-1-1: The target type of a pointer or lvalue reference parameter should be const-qualified appropriately
 * @description Pointer or lvalue reference parameters that do not modify the target object should
 *              be const-qualified to accurately reflect function behavior and prevent unintended
 *              modifications.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-1-1
 *       correctness
 *       readability
 *       performance
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.Pointers
import codingstandards.cpp.Call
import codingstandards.cpp.SideEffect

/**
 * Holds if the function is in a template scope and should be excluded.
 */
predicate isInTemplateScope(Function f) {
  f.isFromTemplateInstantiation(_)
  or
  f.isFromUninstantiatedTemplate(_)
}

/**
 * A `Type` that may be a pointer, array, or reference, to a const or a non-const type.
 *
 * For example, `const int*`, `int* const`, `const int* const`, `int*`, `int&`, `const int&` are all
 * `PointerLikeType`s, while `int`, `int&&`, and `const int` are not.
 *
 * To check if a `PointerLikeType` points/refers to a const-qualified type, use the `pointsToConst()`
 * predicate.
 */
class PointerLikeType extends Type {
  Type innerType;
  Type outerType;

  PointerLikeType() {
    innerType = this.(UnspecifiedPointerOrArrayType).getBaseType() and
    outerType = this
    or
    innerType = this.(LValueReferenceType).getBaseType() and
    outerType = this
    or
    exists(PointerLikeType stripped |
      stripped = this.stripTopLevelSpecifiers() and not stripped = this
    |
      innerType = stripped.getInnerType() and
      outerType = stripped.getOuterType()
    )
  }

  /**
   * Gets the pointed to or referred to type, for instance `int` for `int*` or `const int&`.
   */
  Type getInnerType() { result = innerType }

  /**
   * Gets the resolved pointer, array, or reference type itself, for instance `int*` in `int* const`.
   *
   * Removes cv-qualification and resolves typedefs and decltypes and specifiers via
   * `stripTopLevelSpecifiers()`.
   */
  Type getOuterType() { result = outerType }

  /**
   * Holds when this type points to const -- for example, `const int*` and `const int&` point to
   * const, while `int*`, `int *const` and `int&` do not.
   */
  predicate pointsToConst() { innerType.isConst() }

  /**
   * Holds when this type points to non-const -- for example, `int*` and `int&` and `int *const`
   * point to non-const, while `const int*`, `const int&` do not.
   */
  predicate pointsToNonConst() { not innerType.isConst() }
}

/**
 * A `Parameter` whose type is a `PointerLikeType` such as a pointer or reference.
 */
class PointerLikeParam extends Parameter {
  PointerLikeType pointerLikeType;

  PointerLikeParam() {
    pointerLikeType = this.getType() and
    not pointerLikeType.pointsToConst() and
    // Exclude pointers to non-object types
    not pointerLikeType.getInnerType() instanceof RoutineType
  }

  /**
   * Gets the pointer like type of this parameter.
   */
  PointerLikeType getPointerLikeType() { result = pointerLikeType }

  /**
   * Gets usages of this parameter that maintain pointer-like semantics -- typically this means
   * either a normal access, or switching between pointers and reference semantics.
   *
   * Examples of accesses with pointer-like semantics include:
   * - `ref` in `int &x = ref`, or `&ref` in `int *x = &ref`;
   * - `ptr` in `int *x = ptr`, or `*ptr` in `int &x = *ptr`;
   *
   * In the above examples, we can still access the value pointed to by `ref` or `ptr` through the
   * expression.
   *
   * Examples of non-pointer-like semantics include:
   * - `ref` in `int x = ref` and `*ptr` in `int x = *ptr`;
   *
   * In the above examples, the value pointed to by `ref` or `ptr` is copied and the expression
   * refers to a new/different object.
   */
  Expr getAPointerLikeAccess() {
    result = this.getAnAccess()
    or
    // For reference parameters, also consider accesses to the parameter itself as accesses to the referent
    pointerLikeType.getOuterType() instanceof ReferenceType and
    result.(AddressOfExpr).getOperand() = this.getAnAccess()
    or
    // A pointer is dereferenced, but the result is not copied
    pointerLikeType.getOuterType() instanceof PointerType and
    result.(PointerDereferenceExpr).getOperand() = this.getAnAccess() and
    not any(ReferenceDereferenceExpr rde).getExpr() = result.getConversion+()
  }
}

/**
 * A `VariableEffect` whose target variable is a `PointerLikeParam`.
 *
 * Examples of pointer-like effects on a pointer-like parameter `p` would include `p = ...`, `++p`,
 * `*p = ...`, and `++*p`, etc.
 */
class PointerLikeEffect extends VariableEffect {
  PointerLikeParam param;

  PointerLikeEffect() { param = this.getTarget() }

  /**
   * Holds if this effect modifies the pointed-to or referred-to object.
   *
   * For example, `*p = 0` modifies the inner type if `p` is a pointer, and `p = 0` affects the
   * inner type if `p` is a reference.
   */
  predicate affectsInnerType() {
    if param.getPointerLikeType() instanceof ReferenceType
    then affectsOuterType()
    else not affectsOuterType()
  }

  /**
   * Holds if this effect modifies the pointer or reference itself.
   *
   * For example, `p = ...` and `++p` modify the outer type, whether that type is a pointer or
   * reference, while `*p = 0` does not modify the outer type.
   */
  predicate affectsOuterType() {
    this.(Assignment).getLValue() = param.getAnAccess()
    or
    this.(CrementOperation).getOperand() = param.getAnAccess()
  }
}

/**
 * A candidate parameter that could have its target type const-qualified.
 */
class NonConstParam extends PointerLikeParam {
  NonConstParam() {
    not pointerLikeType.pointsToConst() and
    // Ignore parameters in functions without bodies
    exists(this.getFunction().getBlock()) and
    // Ignore unnamed parameters
    this.isNamed() and
    // Ignore functions that use ASM statements
    not exists(AsmStmt a | a.getEnclosingFunction() = this.getFunction()) and
    // Must have a pointer, array, or lvalue reference type with non-const target
    // Exclude pointers to non-object types
    not pointerLikeType.getInnerType() instanceof RoutineType and
    not pointerLikeType.getInnerType() instanceof VoidType and
    // Exclude virtual functions
    not this.getFunction().isVirtual() and
    // Exclude functions in template scope
    not isInTemplateScope(this.getFunction()) and
    // Exclude main
    not this.getFunction().hasGlobalName("main") and
    // Exclude deleted functions
    not this.getFunction().isDeleted() and
    // Exclude any parameter whose underlying data is modified
    not exists(PointerLikeEffect effect |
      effect.getTarget() = this and
      effect.affectsInnerType()
    ) and
    // Exclude parameters passed as arguments to non-const pointer/ref params
    not exists(CallArgumentExpr arg |
      arg = this.getAPointerLikeAccess() and
      arg.getParamType().(PointerLikeType).pointsToNonConst()
    ) and
    // Exclude parameters used as qualifier for a non-const member function
    not exists(FunctionCall fc |
      fc.getQualifier() = [this.getAnAccess(), this.getAPointerLikeAccess()] and
      not fc.getTarget().hasSpecifier("const") and
      not fc.getTarget().isStatic()
    ) and
    // Exclude parameters assigned to a non-const pointer/reference alias
    not exists(Variable v |
      v.getAnAssignedValue() = this.getAPointerLikeAccess() and
      v.getType().(PointerLikeType).pointsToNonConst()
    ) and
    // Exclude parameters returned as non-const pointer/reference
    not exists(ReturnStmt ret |
      ret.getExpr() = this.getAPointerLikeAccess() and
      ret.getEnclosingFunction().getType().(PointerLikeType).pointsToNonConst()
    ) and
    not exists(FieldAccess fa |
      fa.getQualifier() = [this.getAPointerLikeAccess(), this.getAnAccess()] and
      fa.isLValueCategory()
    ) and
    not exists(AddressOfExpr addrOf |
      // exclude pointer to pointer and reference to pointer cases.
      addrOf.getOperand() = this.getAPointerLikeAccess() and
      addrOf.getType().(PointerLikeType).getInnerType() instanceof PointerLikeType
    ) and
    not exists(PointerArithmeticOperation pointerManip |
      pointerManip.getAnOperand() = this.getAPointerLikeAccess() and
      pointerManip.getType().(PointerLikeType).pointsToNonConst()
    )
  }
}

from NonConstParam param, Type innerType
where
  not isExcluded(param, Declarations6Package::pointerOrRefParamNotConstQuery()) and
  innerType = param.getPointerLikeType().getInnerType() and
  not param.isAffectedByMacro() and
  // There are some odd database patterns where a function has multiple parameters with the same
  // index and different names, due to strange extraction+linker scenarios. These give wrong
  // results, and should be excluded.
  count(Parameter p |
    p.getFunction() = param.getFunction() and
    p.getIndex() = param.getIndex()
  ) = 1
select param,
  "Parameter '" + param.getName() + "' points/refers to a non-const type '" + innerType.toString() +
    "' but does not modify the target object in the $@.", param.getFunction().getDefinition(),
  "function definition"
