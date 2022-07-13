/**
 * @id cpp/autosar/function-missing-constexpr
 * @name A7-1-2: The constexpr specifier shall be used for functions whose return value can be determined at compile time
 * @description Using 'constexpr' makes it clear that a function is intended to return a compile
 *              time constant.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a7-1-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.TrivialType

/** Gets a non-variant member field. */
Field getANonVariantField(Class c) {
  result = c.getAField() and
  result.isInitializable() and
  not result instanceof AnonymousUnionField
}

/**
 * A `Field` holding an "anonymous union" as described by `[class.union]`.
 *
 * For example, the union in this example:
 * ```
 * class C {
 *   union {
 *     int x;
 *     short y;
 *   };
 * }
 * ```
 */
class AnonymousUnionField extends Field {
  AnonymousUnionField() { hasName("(unknown field)") }

  /**
   * Get a direct or indirect union member.
   *
   * Indirect members can come from nested anonymous unions.
   */
  Field getAVariantMember() {
    exists(Field f | f = getType().(Union).getAField() |
      if f instanceof AnonymousUnionField
      then result = f.(AnonymousUnionField).getAVariantMember()
      else result = f
    )
  }

  /**
   * Holds if one variant member of this anonymous union field is initialized using NSDMI.
   */
  predicate isExplicitlyInitialized() { exists(getAVariantMember().getInitializer().getExpr()) }
}

/**
 * Get a union which is not initialized by NSDMI.
 */
AnonymousUnionField getAnUninitializedAnonymousUnionField(Class c) {
  result = c.getAField() and
  not result.isExplicitlyInitialized()
}

/**
 * A function that can be `constexpr` specified according to the constraints for a `constexpr`
 * function as specified in `[dcl.constexpr]/3`.
 */
class EffectivelyConstExprFunction extends Function {
  EffectivelyConstExprFunction() {
    // Not already marked as constexpr
    not isDeclaredConstexpr() and
    // Not virtual
    not isVirtual() and
    // Returns a literal type (which can be 'void')
    (isLiteralType(getType()) or this instanceof Constructor) and
    // Exclude cases that shouldn't be const or can't be const
    not this instanceof Destructor and
    not this instanceof CopyAssignmentOperator and
    not this instanceof MoveAssignmentOperator and
    not this.isCompilerGenerated() and
    // All parameters are literal types
    forall(Parameter p | p = getAParameter() | isLiteralType(p.getType())) and
    // The function body is either deleted, defaulted or does not include one of the precluding
    // statement kinds and is both side-effect free and created by the user
    (
      isDeleted()
      or
      isDefaulted()
      or
      not this = any(AsmStmt a).getEnclosingFunction() and
      not this = any(GotoStmt g).getEnclosingFunction() and
      not this = any(TryStmt t).getEnclosingFunction() and
      not exists(LocalVariable lv | this = lv.getFunction() |
        not isLiteralType(lv.getType())
        or
        lv instanceof StaticStorageDurationVariable
        or
        lv.isThreadLocal()
        or
        not exists(lv.getInitializer().getExpr())
      ) and
      // For `constexpr` functions, the compiler only checks the rules above - it doesn't check
      // whether the function can be evaluated as a compile time constant until the function is used,
      // and then only confirms that it evaluates to a compile-time constant for a specific set of
      // arguments used in another constexpr calculation. We approximate this by identifying the set
      // of functions that are (conservatively) side-effect free.
      isSideEffectFree() and
      // "User defined" in some way
      hasDefinition() and
      not isCompilerGenerated()
    ) and
    (
      // A constructor should satisfy the constraints as specified in `[dcl.constexpr]/4`.
      this instanceof Constructor
      implies
      (
        // No virtual base class
        not getDeclaringType().getDerivation(_).isVirtual() and
        (
          // All non-variant members initialized by this constructor
          forall(Field f | f = getANonVariantField(getDeclaringType()) |
            exists(ConstructorFieldInit cfi |
              // Even if this field has a `getInitializer()` a `ConstructorFieldInit` will also be
              // present on each constructor
              cfi.getEnclosingFunction() = this and cfi.getTarget() = f
            )
          ) and
          // At least one variant member is initialized for each `AnonymousUnionField` which is not
          // initialized with a `Field.getInitializer()`. This is different to the non-variant
          // member case above
          forall(AnonymousUnionField f |
            f = getAnUninitializedAnonymousUnionField(getDeclaringType())
          |
            exists(ConstructorFieldInit cfi |
              cfi.getEnclosingFunction() = this and cfi.getTarget() = f.getAVariantMember()
            )
          )
          or
          // The function is deleted or defaulted, and every field has an NSDMI, and there are no
          // uninitialized anonymous union fields
          (isDeleted() or isDefaulted()) and
          forall(Field f | f = getANonVariantField(getDeclaringType()) |
            exists(f.getInitializer().getExpr())
          ) and
          not exists(getAnUninitializedAnonymousUnionField(getDeclaringType()))
        )
      )
    )
  }
}

from EffectivelyConstExprFunction ecef
where not isExcluded(ecef, ConstPackage::functionMissingConstexprQuery())
select ecef, ecef.getName() + " function could be marked as 'constexpr'."
