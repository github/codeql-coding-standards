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
 * Holds if `f` is a `Function` in a template scope and should be excluded.
 */
predicate isInTemplateScope(Function f) {
  f.isFromTemplateInstantiation(_)
  or
  f.isFromUninstantiatedTemplate(_)
}

/**
 * A `Parameter` whose type is a `PointerLikeType` such as a pointer or reference.
 */
class PointerLikeParam extends Parameter {
  PointerLikeType pointerLikeType;

  PointerLikeParam() {
    pointerLikeType = this.getType() and
    not pointerLikeType.pointsToConst()
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
  Expr getAPointerLikeAccess() { result = getAPointerLikeAccessOf(this.getAnAccess()) }
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
    not pointerLikeType.getInnerType+().getUnderlyingType() instanceof RoutineType and
    not pointerLikeType.getInnerType+().getUnderlyingType() instanceof VoidType and
    // Exclude virtual functions
    not this.getFunction().isVirtual() and
    // Exclude functions in template scope
    not isInTemplateScope(this.getFunction()) and
    // Exclude main
    not this.getFunction().hasGlobalName("main") and
    // Exclude deleted functions
    not this.getFunction().isDeleted() and
    // Exclude any parameter whose underlying data is modified
    not exists(AliasParameter alias | alias = this | alias.isModified()) and
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
