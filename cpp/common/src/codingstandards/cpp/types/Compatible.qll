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
 * `interestedInEquality` that restricts the set of considered types.
 *
 * To use this module, define a `TypeEquivalenceSig` module and implement a subset of `Type` that
 * selects the relevant root types to be considered. Then use the predicate `equalTypes(a, b)`.
 * Note that `equalTypes(a, b)` only holds if `interestedIn(a, b)` holds. A type is always
 * considered to be equal to itself, and this module does not support configurations that declare
 * otherwise.
 * 
 * Further, `interestedInEquality(a, a)` is treated differently from `interestedInEquality(a, b)`,
 * assuming that `a` and `b` are not identical. This is so that we can construct a set of types
 * that are not identical, but still may be equivalent by the specified configuration. We also must
 * consider all types that are reachable from these types, as the equivalence relation is
 * recursive. Therefore, this module is more performant when most comparisons are identical, and
 * only a few are not.
 */
module TypeEquivalence<TypeEquivalenceSig Config, interestedInEquality/2 interestedIn> {
  /**
   * Check whether two types are equivalent, as defined by the `TypeEquivalenceSig` module.
   * 
   * This only holds if the specified predicate `interestedIn` holds for the types, and always
   * holds if `t1` and `t2` are identical.
   */
  predicate equalTypes(Type t1, Type t2) {
    interestedInUnordered(t1, t2) and
    (
      // If the types are identical, they are trivially equal.
      t1 = t2
      or
      not t1 = t2 and
      equalTypesImpl(t1, t2)
    )
  }

  /**
   * This implementation handles only the slow and complex cases of type equivalence, where the
   * types are not identical.
   *
   * Assuming that types a, b must be compared where `a` and `b` are not identical, we wish to
   * search only the smallest set of possible relevant types. See `RelevantType` for more.
   */
  private predicate equalTypesImpl(RelevantType t1, RelevantType t2) {
    if Config::overrideTypeComparison(t1, t2, _)
    then Config::overrideTypeComparison(t1, t2, true)
    else
      if t1 instanceof TypedefType and Config::resolveTypedefs()
      then equalTypesImpl(t1.(TypedefType).getBaseType(), t2)
      else
        if t2 instanceof TypedefType and Config::resolveTypedefs()
        then equalTypesImpl(t1, t2.(TypedefType).getBaseType())
        else (
          not t1 instanceof DerivedType and
          not t2 instanceof DerivedType and
          not t1 instanceof TypedefType and
          not t2 instanceof TypedefType and
          LeafEquiv::getEquivalenceClass(t1) = LeafEquiv::getEquivalenceClass(t2)
          or
          equalDerivedTypes(t1, t2)
          or
          equalTypedefTypes(t1, t2)
          or
          equalFunctionTypes(t1, t2)
        )
  }

  /** Whether two types will be compared, regardless of order (a, b) or (b, a). */
  private predicate interestedInUnordered(Type t1, Type t2) {
    interestedIn(t1, t2) or
    interestedIn(t2, t1) }

  final private class FinalType = Type;

  /**
   * A type that is compared to another type that is not identical. This is the set of types that
   * form the roots of our more expensive type equivalence analysis.
   */
  private class InterestingType extends FinalType {
    InterestingType() {
      exists(Type inexactCompare |
        interestedInUnordered(this, _) and
        not inexactCompare = this
      )
    }
  }

  /**
   * A type that is reachable from an `InterestingType` (a type that is compared to a non-identical
   * type).
   * 
   * Since type equivalence is recursive, CodeQL will consider the equality of these types in a
   * bottom-up evaluation, with leaf nodes first. Therefore, this set must be as small as possible
   * in order to be efficient.
   */
  private class RelevantType extends FinalType {
    RelevantType() { exists(InterestingType t | typeGraph*(t, this)) }
  }

  private class RelevantDerivedType extends RelevantType instanceof DerivedType {
    RelevantType getBaseType() { result = this.(DerivedType).getBaseType() }
  }

  private class RelevantFunctionType extends RelevantType instanceof FunctionType {
    RelevantType getReturnType() { result = this.(FunctionType).getReturnType() }

    RelevantType getParameterType(int i) { result = this.(FunctionType).getParameterType(i) }
  }

  private class RelevantTypedefType extends RelevantType instanceof TypedefType {
    RelevantType getBaseType() { result = this.(TypedefType).getBaseType() }
  }

  private module LeafEquiv = QlBuiltins::EquivalenceRelation<RelevantType, equalLeafRelation/2>;

  private predicate equalLeafRelation(RelevantType t1, RelevantType t2) {
    Config::equalLeafTypes(t1, t2)
  }

  private RelevantType unspecify(SpecifiedType t) {
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
  private predicate equalDerivedTypes(RelevantDerivedType t1, RelevantDerivedType t2) {
    exists(Boolean baseTypesEqual |
      (baseTypesEqual = true implies equalTypesImpl(t1.getBaseType(), t2.getBaseType())) and
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
      (unspecifiedTypesEqual = true implies equalTypesImpl(unspecify(t1), unspecify(t2))) and
      Config::equalSpecifiedTypes(t1, t2, unspecifiedTypesEqual)
    )
  }

  bindingset[t1, t2]
  private predicate equalFunctionTypes(RelevantFunctionType t1, RelevantFunctionType t2) {
    exists(Boolean returnTypeEqual, Boolean parameterTypesEqual |
      (returnTypeEqual = true implies equalTypesImpl(t1.getReturnType(), t2.getReturnType())) and
      (
        parameterTypesEqual = true
        implies
        forall(int i | exists([t1, t2].getParameterType(i)) |
          equalTypesImpl(t1.getParameterType(i), t2.getParameterType(i))
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
  private predicate equalTypedefTypes(RelevantTypedefType t1, RelevantTypedefType t2) {
    exists(Boolean baseTypesEqual |
      (baseTypesEqual = true implies equalTypesImpl(t1.getBaseType(), t2.getBaseType())) and
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
      interestedInFunctions(aFun, bFun) and
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
