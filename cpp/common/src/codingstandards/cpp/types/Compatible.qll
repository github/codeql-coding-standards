import cpp
import codeql.util.Boolean
import codingstandards.cpp.types.Graph

module TypeNamesMatchConfig implements TypeEquivalenceSig {
  predicate resolveTypedefs() {
    // We don't want to resolve typedefs here, as we want to compare the names of the types.
    none()
  }
}

/**
 * The set of types that are used in function signatures.
 */
class FunctionSignatureType extends Type {
  FunctionSignatureType() {
    exists(FunctionDeclarationEntry f |
      this = f.getType() or this = f.getAParameterDeclarationEntry().getType()
    )
  }
}

class VariableType extends Type {
  VariableType() { this = any(VariableDeclarationEntry v).getType() }
}

predicate parameterNamesUnmatched(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  pragma[only_bind_into](f1).getDeclaration() = pragma[only_bind_into](f2).getDeclaration() and
  exists(string p1Name, string p2Name, int i |
    p1Name = f1.getParameterDeclarationEntry(i).getName() and
    p2Name = f2.getParameterDeclarationEntry(i).getName()
  |
    not p1Name = p2Name
  )
}

/**
 * Implements type compatibility as defined in C17, assuming typedefs have already been resolved.
 *
 * The default TypeEquivalence already handles the following:
 *  - A type is compatible with itself
 *  - All specifiers must match, but the order does not matter
 *  - Function types are compatible if they have the same return type and compatible parameters.
 *
 * Additional override for array sizes and enums are added here.
 */
module TypesCompatibleConfig implements TypeEquivalenceSig {
  bindingset[t1, t2]
  predicate equalLeafTypes(Type t1, Type t2) {
    t1 = t2
    or
    t1.(IntegralType).getCanonicalArithmeticType() = t2.(IntegralType).getCanonicalArithmeticType()
    or
    // Enum types are compatible with one of char, int, or signed int, but the implementation
    // decides.
    t1 instanceof Enum and
    (t2 instanceof CharType or t2 instanceof IntType)
    or
    t2 instanceof Enum and
    (t1 instanceof CharType or t1 instanceof IntType)
  }

  bindingset[t1, t2]
  predicate equalArrayTypes(ArrayType t1, ArrayType t2, Boolean baseTypesEqual) {
    baseTypesEqual = true and
    // Compatible array types have compatible element types. If both have a constant size then that
    // size must match.
    count(int i | i = [t1, t2].(ArrayType).getSize()) < 2
  }
}

/**
 * Utilize QlBuiltins::InternSets to efficiently compare the sets of specifiers on two types.
 */
bindingset[t1, t2]
private predicate specifiersMatchExactly(Type t1, Type t2) {
  t1 = t2
  or
  SpecifierSet::getSet(t1) = SpecifierSet::getSet(t2)
}

/**
 * Base predicate for `QlBuiltins::InternSets` to get the specifier set for a type.
 *
 * Note that this also efficiently handles complex typedef cases, where a specified type points to
 * a typedef that points to another specified type. In this case, `getASpecifier()` will return all
 * of specifiers, not just those above the TypedefType.
 */
Specifier getASpecifier(SpecifiedType key) { result = key.getASpecifier() }

module SpecifierSet = QlBuiltins::InternSets<SpecifiedType, Specifier, getASpecifier/1>;

/**
 * Signature module for handling various kinds of potentially recursive type equivalence using the
 * module `TypeEquivalence<T>`.
 *
 * The various kinds of types to be compared all have an overridable predicate with default
 * behavior here, and a boolean flag that indicates whether the base types are equal. This pattern
 * is used because we can't make a default implementation of a predicate such as
 * `equalPointerTypes` that recurses into the `TypeEquivalence` module. Instead, the
 * `TypeEquivalence` module drives all of the recursion, and these predicates take the result of
 * that recursion and use it to determine whether the types are equivalent.
 */
signature module TypeEquivalenceSig {
  /**
   * Whether two leaf types are equivalent, such as `int`s and structs. By default, we assume only
   * that types are equal to themselves and that equivalent arithmetic types are equal.
   */
  bindingset[t1, t2]
  default predicate equalLeafTypes(Type t1, Type t2) {
    t1 = t2
    or
    t1.(IntegralType).getCanonicalArithmeticType() = t2.(IntegralType).getCanonicalArithmeticType()
  }

  /**
   * A predicate to arbitrarily override the default behavior of the `TypeEquivalence` module,
   * including preventing recursion. If this predicate holds for a pair of types, then
   * `TypeEquivalence::equalTypes()` holds only if `areEqual` is true.
   */
  bindingset[t1, t2]
  default predicate overrideTypeComparison(Type t1, Type t2, Boolean areEqual) { none() }

  /**
   * Whether two specified types are equivalent. By default, we assume that the specifier sets are
   * exactly the same, and the inner types also match.
   */
  bindingset[t1, t2]
  default predicate equalSpecifiedTypes(
    SpecifiedType t1, SpecifiedType t2, Boolean unspecifiedTypesEqual
  ) {
    specifiersMatchExactly(t1, t2) and
    unspecifiedTypesEqual = true
  }

  /**
   * Whether two specified types are equivalent. By default, we only require that the base (pointed
   * to) types match.
   */
  bindingset[t1, t2]
  default predicate equalPointerTypes(PointerType t1, PointerType t2, Boolean baseTypesEqual) {
    baseTypesEqual = true
  }

  /**
   * Whether two array types are equivalent. By default, we only require that the element types and
   * array sizes match.
   */
  bindingset[t1, t2]
  default predicate equalArrayTypes(ArrayType t1, ArrayType t2, Boolean baseTypesEqual) {
    t1.getSize() = t2.getSize() and
    baseTypesEqual = true
  }

  /**
   * Whether two reference types are equivalent. By default, we only require that the base types match.
   */
  bindingset[t1, t2]
  default predicate equalReferenceTypes(ReferenceType t1, ReferenceType t2, Boolean baseTypesEqual) {
    baseTypesEqual = true
  }

  /**
   * Whether typedefs should be resolved before comparison. By default, we assume `TypeEquivalence`
   * should resolve typedefs before comparison.
   */
  default predicate resolveTypedefs() { any() }

  /**
   * Whether two typedef types are equivalent.
   *
   * This predicate is only used if `resolveTypedefs()` is false. If so, then we assume two
   * typedefs are the same if they have the same name and their base types are equal.
   */
  bindingset[t1, t2]
  default predicate equalTypedefTypes(TypedefType t1, TypedefType t2, Boolean baseTypesEqual) {
    t1.getName() = t2.getName() and
    baseTypesEqual = true
  }

  /**
   * Whether two routine types are equivalent. By default, we only require that the return types and
   * parameter types match.
   */
  bindingset[t1, t2]
  default predicate equalRoutineTypes(
    RoutineType t1, RoutineType t2, Boolean returnTypeEqual, Boolean parameterTypesEqual
  ) {
    returnTypeEqual = true and parameterTypesEqual = true
  }

  /**
   * Whether two function pointer/reference types are equivalent. By default, we only require that
   * the return types and parameter types match.
   */
  bindingset[t1, t2]
  default predicate equalFunctionPointerIshTypes(
    FunctionPointerIshType t1, FunctionPointerIshType t2, Boolean returnTypeEqual,
    Boolean parameterTypesEqual
  ) {
    returnTypeEqual = true and parameterTypesEqual = true
  }
}

/**
 * The default equivalence behavior for the `TypeEquivalence` module.
 */
module DefaultEquivalence implements TypeEquivalenceSig { }

/**
 * A signature predicate used to restrict the set of types considered by `TypeEquivalence`, for
 * performance reasons.
 */
signature predicate interestedInEquality(Type a, Type b);

/**
 * A module to check the equivalence of two types, as defined by the provided `TypeEquivalenceSig`.
 *
 * For performance reasons, this module is designed to be used with a predicate
 * `interestedInEquality` that restricts the set of considered pairwise comparisons.
 *
 * To use this module, define a `TypeEquivalenceSig` module and implement a subset of `Type` that
 * selects the relevant root types to be considered. Then use the predicate `equalTypes(a, b)`.
 * Note that `equalTypes(a, b)` only holds if `interestedIn(a, b)` holds. A type is always
 * considered to be equal to itself, and this module does not support configurations that declare
 * otherwise. Additionally, `interestedIn(a, b)` implies `interestedIn(b, a)`.
 *
 * This module will recursively select pairs of types to be compared. For instance, if
 * `interestedInEquality(a, b)` holds, then types `a` and `b` will be compared. If
 * `Config::equalPointerTypes(a, b, true)` holds, then the pointed-to types of `a` and `b` will be
 * compared. However, if `Config::equalPointerTypes(a, b, false)` holds, then `a` and `b` will be
 * compared, but their pointed-to types will not. Similarly, inner types will not be compared if
 * `Config::overrideTypeComparison(a, b, _)` holds. For detail, see the module predicates
 * `shouldRecurseOn` and `interestedInNestedTypes`.
 */
module TypeEquivalence<TypeEquivalenceSig Config, interestedInEquality/2 interestedIn> {
  /**
   * Performance-related predicate that holds for a pair of types `(a, b)` such that
   * `interestedIn(a, b)` holds, or there exists a pair of types `(c, d)` such that
   * `interestedIn(c, d)` holds, and computing `equalTypes(a, b)` requires computing
   * `equalTypes(c, d)`.
   *
   * The goal of this predicate is to force top down rather than bottom up evaluation of type
   * equivalence. That is to say, if we compare array types `int[]` and `int[]`, we to compare that
   * both types are arrays first, and then compare that their base types are equal. Naively, CodeQL
   * is liable to compute this kind of recursive equality in a bottom up fashion, where the cross
   * product of all types is considered in computing `equalTypes(a, b)`.
   *
   * This interoperates with the predicate `shouldRecurseOn` to find types that will be compared,
   * along with the inner types of those types that will be compared. See `shouldRecurseOn` for
   * cases where this algorithm will or will not recurse. We still need to know which types are
   * compared, even if we do not recurse on them, in order to properly constrain `equalTypes(x, y)`
   * to hold for types such as leaf types, where we do not recurse during comparison.
   *
   * At each stage of recursion, we specify `pragma[only_bind_into]` to ensure that the
   * prior `shouldRecurseOn` results are considered first in the pipeline.
   */
  private predicate interestedInNestedTypes(Type t1, Type t2) {
    // Base case: config specifies that these root types will be compared.
    interestedInUnordered(t1, t2)
    or
    // If derived types are compared, their base types must be compared.
    exists(DerivedType t1Derived, DerivedType t2Derived |
      not t1Derived instanceof SpecifiedType and
      not t2Derived instanceof SpecifiedType and
      shouldRecurseOn(pragma[only_bind_into](t1Derived), pragma[only_bind_into](t2Derived)) and
      t1 = t1Derived.getBaseType() and
      t2 = t2Derived.getBaseType()
    )
    or
    // If specified types are compared, their unspecified types must be compared.
    exists(SpecifiedType t1Spec, SpecifiedType t2Spec |
      shouldRecurseOn(pragma[only_bind_into](t1Spec), pragma[only_bind_into](t2Spec)) and
      (
        t1 = unspecify(t1Spec) and
        t2 = unspecify(t2Spec)
      )
    )
    or
    // If function types are compared, their return types and parameter types must be compared.
    exists(FunctionType t1Func, FunctionType t2Func |
      shouldRecurseOn(pragma[only_bind_into](t1Func), pragma[only_bind_into](t2Func)) and
      (
        t1 = t1Func.getReturnType() and
        t2 = t2Func.getReturnType()
        or
        exists(int i |
          t1 = t1Func.getParameterType(pragma[only_bind_out](i)) and
          t2 = t2Func.getParameterType(i)
        )
      )
    )
    or
    // If the config says to resolve typedefs, and a typedef type is compared to a non-typedef
    // type, then the non-typedef type must be compared to the base type of the typedef.
    Config::resolveTypedefs() and
    exists(TypedefType tdtype |
      tdtype.getBaseType() = t1 and
      shouldRecurseOn(pragma[only_bind_into](tdtype), t2)
      or
      tdtype.getBaseType() = t2 and
      shouldRecurseOn(t1, pragma[only_bind_into](tdtype))
    )
    or
    // If two typedef types are compared, then their base types must be compared.
    exists(TypedefType t1Typedef, TypedefType t2Typedef |
      shouldRecurseOn(pragma[only_bind_into](t1Typedef), pragma[only_bind_into](t2Typedef)) and
      (
        t1 = t1Typedef.getBaseType() and
        t2 = t2Typedef.getBaseType()
      )
    )
  }

  /**
   * Performance related predicate to force top down rather than bottom up evaluation of type
   * equivalence.
   *
   * This predicate is used to determine whether we should recurse on a type. It is used in
   * conjunction with the `interestedInNestedTypes` predicate to only recurse on types that are
   * being compared.
   *
   * We don't recurse on identical types, as they are already equal. We also don't recurse on
   * types that are overriden by `Config::overrideTypeComparison`, as that predicate determines
   * their equalivance.
   *
   * For the other types, we have a set of predicates such as `Config::equalPointerTypes` that
   * holds for `(x, y, true)` if the types `x` and `y` should be considered equivalent when the
   * pointed-to types of `x` and `y` are equivalent. If the predicate does not hold, or holds for
   * `(x, y, false)`, then we do not recurse on the types.
   *
   * We do not recurse on leaf types.
   */
  private predicate shouldRecurseOn(Type t1, Type t2) {
    // We only recurse on types we are comparing.
    interestedInNestedTypes(pragma[only_bind_into](t1), pragma[only_bind_into](t2)) and
    // We don't recurse on identical types, as they are already equal.
    not t1 = t2 and
    // We don't recurse on overriden comparisons
    not Config::overrideTypeComparison(t1, t2, _) and
    (
      // These pointer types are equal if their base types are equal: recurse.
      Config::equalPointerTypes(t1, t2, true)
      or
      // These array types are equal if their base types are equal: recurse.
      Config::equalArrayTypes(t1, t2, true)
      or
      // These reference types are equal if their base types are equal: recurse.
      Config::equalReferenceTypes(t1, t2, true)
      or
      // These routine types are equal if their return and parameter types are equal: recurse.
      Config::equalRoutineTypes(t1, t2, true, true)
      or
      // These function pointer-ish types are equal if their return and parameter types are equal: recurse.
      Config::equalFunctionPointerIshTypes(t1, t2, true, true)
      or
      // These typedef types are equal if their base types are equal: recurse.
      Config::equalTypedefTypes(t1, t2, true)
      or
      // These specified types are equal if their unspecified types are equal: recurse.
      Config::equalSpecifiedTypes(t1, t2, true)
      or
      // We resolve typedefs, and one of these types is a typedef type: recurse.
      Config::resolveTypedefs() and
      (
        t1 instanceof TypedefType
        or
        t2 instanceof TypedefType
      )
    )
  }

  /**
   * Check whether two types are equivalent, as defined by the `TypeEquivalenceSig` module.
   *
   * This only holds if the specified predicate `interestedIn` holds for the types, or
   * `interestedInNestedTypes` holds for the types, and holds if `t1` and `t2` are identical,
   * regardless of how `TypeEquivalenceSig` is defined.
   */
  predicate equalTypes(Type t1, Type t2) {
    interestedInNestedTypes(pragma[only_bind_into](t1), pragma[only_bind_into](t2)) and
    (
      t1 = t2
      or
      not t1 = t2 and
      if Config::overrideTypeComparison(t1, t2, _)
      then Config::overrideTypeComparison(t1, t2, true)
      else (
        equalLeafRelation(t1, t2)
        or
        equalDerivedTypes(t1, t2)
        or
        equalFunctionTypes(t1, t2)
        or
        Config::resolveTypedefs() and
        (
          equalTypes(t1.(TypedefType).getBaseType(), t2)
          or
          equalTypes(t1, t2.(TypedefType).getBaseType())
        )
        or
        not Config::resolveTypedefs() and
        equalTypedefTypes(t1, t2)
      )
    )
  }

  /** Whether two types will be compared, regardless of order (a, b) or (b, a). */
  private predicate interestedInUnordered(Type t1, Type t2) {
    interestedIn(t1, t2) or
    interestedIn(t2, t1)
  }

  bindingset[t1, t2]
  private predicate equalLeafRelation(LeafType t1, LeafType t2) { Config::equalLeafTypes(t1, t2) }

  bindingset[t]
  private Type unspecify(SpecifiedType t) {
    // This subtly and importantly handles the complicated cases of typedefs. Under most scenarios,
    // if we see a typedef in `equalTypes()` we can simply get the base type and continue. However,
    // there is an exception if we have a specified type that points to a typedef that points to
    // another specified type. In this case, `SpecifiedType::getASpecifier()` will return all of
    // specifiers, not just those above the TypedefType, and `stripTopLevelSpecifiers` will return
    // the innermost type that is not a TypedefType or a SpecifiedType, which is what we want, as
    // all specifiers have already been accounted for when we visit the outermost `SpecifiedType`.
    if Config::resolveTypedefs()
    then result = t.(SpecifiedType).stripTopLevelSpecifiers()
    else result = t.(SpecifiedType).getBaseType()
  }

  bindingset[t1, t2]
  private predicate equalDerivedTypes(DerivedType t1, DerivedType t2) {
    exists(Boolean baseTypesEqual |
      (baseTypesEqual = true implies equalTypes(t1.getBaseType(), t2.getBaseType())) and
      (
        Config::equalPointerTypes(t1, t2, baseTypesEqual)
        or
        Config::equalArrayTypes(t1, t2, baseTypesEqual)
        or
        Config::equalReferenceTypes(t1, t2, baseTypesEqual)
      )
    )
    or
    exists(Boolean unspecifiedTypesEqual |
      // Note that this case is different from the above, in that we don't merely get the base
      // type (as that could be a TypedefType that points to another SpecifiedType). We need to
      // unspecify the type to see if the base types are equal.
      (unspecifiedTypesEqual = true implies equalTypes(unspecify(t1), unspecify(t2))) and
      Config::equalSpecifiedTypes(t1, t2, unspecifiedTypesEqual)
    )
  }

  bindingset[t1, t2]
  private predicate equalFunctionTypes(FunctionType t1, FunctionType t2) {
    exists(Boolean returnTypeEqual, Boolean parameterTypesEqual |
      (returnTypeEqual = true implies equalTypes(t1.getReturnType(), t2.getReturnType())) and
      (
        parameterTypesEqual = true
        implies
        forall(int i | exists([t1, t2].getParameterType(i)) |
          equalTypes(t1.getParameterType(i), t2.getParameterType(i))
        )
      ) and
      (
        Config::equalRoutineTypes(t1, t2, returnTypeEqual, parameterTypesEqual)
        or
        Config::equalFunctionPointerIshTypes(t1, t2, returnTypeEqual, parameterTypesEqual)
      )
    )
  }

  bindingset[t1, t2]
  private predicate equalTypedefTypes(TypedefType t1, TypedefType t2) {
    exists(Boolean baseTypesEqual |
      (baseTypesEqual = true implies equalTypes(t1.getBaseType(), t2.getBaseType())) and
      Config::equalTypedefTypes(t1, t2, baseTypesEqual)
    )
  }
}

signature predicate interestedInFunctionDeclarations(
  FunctionDeclarationEntry f1, FunctionDeclarationEntry f2
);

module FunctionDeclarationTypeEquivalence<
  TypeEquivalenceSig Config, interestedInFunctionDeclarations/2 interestedInFunctions>
{
  private predicate interestedInReturnTypes(Type a, Type b) {
    exists(FunctionDeclarationEntry aFun, FunctionDeclarationEntry bFun |
      interestedInFunctions(pragma[only_bind_into](aFun), pragma[only_bind_into](bFun)) and
      a = aFun.getType() and
      b = bFun.getType()
    )
  }

  private predicate interestedInParameterTypes(Type a, Type b) {
    exists(FunctionDeclarationEntry aFun, FunctionDeclarationEntry bFun, int i |
      interestedInFunctions(pragma[only_bind_into](aFun), pragma[only_bind_into](bFun)) and
      a = aFun.getParameterDeclarationEntry(i).getType() and
      b = bFun.getParameterDeclarationEntry(i).getType()
    )
  }

  predicate equalReturnTypes(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
    interestedInFunctions(f1, f2) and
    TypeEquivalence<Config, interestedInReturnTypes/2>::equalTypes(f1.getType(), f2.getType())
  }

  predicate equalParameterTypes(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
    interestedInFunctions(f1, f2) and
    f1.getDeclaration() = f2.getDeclaration() and
    forall(int i | exists([f1, f2].getParameterDeclarationEntry(i)) |
      equalParameterTypesAt(f1, f2, pragma[only_bind_into](i))
    )
  }

  predicate equalParameterTypesAt(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2, int i) {
    interestedInFunctions(f1, f2) and
    f1.getDeclaration() = f2.getDeclaration() and
    TypeEquivalence<Config, interestedInParameterTypes/2>::equalTypes(f1.getParameterDeclarationEntry(pragma[only_bind_into](i))
          .getType(), f2.getParameterDeclarationEntry(pragma[only_bind_into](i)).getType())
  }
}

/**
 * Convenience class to reduce the awkwardness of how `RoutineType` and `FunctionPointerIshType`
 * don't have a common ancestor.
 */
private class FunctionType extends Type {
  FunctionType() { this instanceof RoutineType or this instanceof FunctionPointerIshType }

  Type getReturnType() {
    result = this.(RoutineType).getReturnType() or
    result = this.(FunctionPointerIshType).getReturnType()
  }

  Type getParameterType(int i) {
    result = this.(RoutineType).getParameterType(i) or
    result = this.(FunctionPointerIshType).getParameterType(i)
  }
}

private class LeafType extends Type {
  LeafType() {
    not this instanceof DerivedType and
    not this instanceof FunctionType and
    not this instanceof FunctionType
  }
}
