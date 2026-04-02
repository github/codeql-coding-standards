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
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.Pointers
import codingstandards.cpp.SideEffect
import codingstandards.cpp.alertreporting.HoldsForAllCopies

/**
 * Holds if the function is in a template scope and should be excluded.
 */
predicate isInTemplateScope(Function f) {
  // Function templates
  f.isFromTemplateInstantiation(_)
  or
  f instanceof TemplateFunction
  or
  // Functions declared within the scope of a template class
  exists(TemplateClass tc | f.getDeclaringType() = tc)
  or
  f.getDeclaringType().isFromTemplateInstantiation(_)
  or
  // Lambdas within template scope
  exists(LambdaExpression le |
    le.getLambdaFunction() = f and
    isInTemplateScope(le.getEnclosingFunction())
  )
}

/**
 * A `Type` that may be a pointer, array, or reference, to a const or a non-const type.
 *
 * For example, `const int*`, `int* const`, `cont int* const`, `int*`, `int&`, `const int&` are all
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
   * Get the pointed to or referred to type, for instance `int` for `int*` or `const int&`.
   */
  Type getInnerType() { result = innerType }

  /**
   * Get the resolved pointer, array, or reference type itself, for instance `int*` in `int* const`.
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
   * Holds when this type points to non-const -- for example, `int*` and `int&` and `int const*`
   * point to non-const, while `const int*`, `const int&` do not.
   */
  predicate pointsToNonConst() { not innerType.isConst() }
}

class PointerLikeParam extends Parameter {
  PointerLikeType pointerLikeType;

  PointerLikeParam() {
    pointerLikeType = this.getType() and
    not pointerLikeType.pointsToConst() and
    // Exclude pointers to non-object types
    not pointerLikeType.getInnerType() instanceof RoutineType and
    not pointerLikeType.getInnerType() instanceof VoidType
  }

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

query predicate test(
  PointerLikeParam param, Expr ptrLikeAccess, Type argtype, Type innerType, string explain
) {
  ptrLikeAccess = param.getAPointerLikeAccess() and
  exists(FunctionCall fc |
    fc.getArgument(0) = ptrLikeAccess and
    argtype = fc.getTarget().getParameter(0).getType() and
    argtype.(PointerLikeType).pointsToNonConst() and
    innerType = argtype.(PointerLikeType).getInnerType()
  ) and
  explain = argtype.explain()
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
    // Exclude any parameter whose underlying data is modified (VariableEffect)
    not exists(VariableEffect effect |
      effect.getTarget() = this and
      (
        // For reference types, any effect is a target modification
        pointerLikeType.getOuterType() instanceof ReferenceType
        or
        // For pointer types, exclude effects that only modify the pointer itself
        not effect.(AssignExpr).getLValue() = this.getAnAccess() and
        not effect.(CrementOperation).getOperand() = this.getAnAccess()
      )
    ) and
    // Exclude parameters passed as arguments to functions taking non-const pointer/ref params
    not exists(FunctionCall fc, int i |
      fc.getArgument(i) = this.getAPointerLikeAccess() and
      fc.getTarget().getParameter(i).getType().(PointerLikeType).pointsToNonConst()
    ) and
    // Exclude parameters used as qualifier for a non-const member function
    not exists(FunctionCall fc |
      fc.getQualifier() = this.getAnAccess() and
      not fc.getTarget().hasSpecifier("const") and
      not fc.getTarget().isStatic()
    ) and
    // Exclude parameters assigned to a non-const pointer/reference alias
    not exists(Variable v |
      v.getAnAssignedValue() = this.getAnAccess() and
      v.getType().(PointerLikeType).pointsToNonConst()
    ) and
    // Exclude parameters returned as non-const pointer/reference
    not exists(ReturnStmt ret |
      ret.getExpr() = this.getAnAccess() and
      ret.getEnclosingFunction().getType().(PointerLikeType).pointsToNonConst()
    )
  }
}

from NonConstParam param
where not isExcluded(param, Declarations3Package::pointerOrRefParamNotConstQuery())
select param,
  "Parameter '" + param.getName() +
    "' points/refers to a non-const-qualified type but does not modify the target object."
