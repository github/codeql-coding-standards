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
  f1.getDeclaration() = f2.getDeclaration() and
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
    [t1, t2] instanceof Enum and
    ([t1, t2] instanceof CharType or [t1, t2] instanceof IntType)
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
 * A signature class used to restrict the set of types considered by `TypeEquivalence`, for
 * performance reasons.
 */
signature class TypeSubset extends Type;

/**
 * A module to check the equivalence of two types, as defined by the provided `TypeEquivalenceSig`.
 *
 * For performance reasons, this module is designed to be used with a `TypeSubset` that restricts
 * the set of considered types. All types reachable (in the type graph) from a type in the subset
 * will be considered. (See `RelevantType`.)
 *
 * To use this module, define a `TypeEquivalenceSig` module and implement a subset of `Type` that
 * selects the relevant root types to be considered. Then use the predicate `equalTypes(a, b)`.
 */
module TypeEquivalence<TypeEquivalenceSig Config, TypeSubset T> {
  /**
   * Check whether two types are equivalent, as defined by the `TypeEquivalenceSig` module.
   */
  predicate equalTypes(RelevantType t1, RelevantType t2) {
    if Config::overrideTypeComparison(t1, t2, _)
    then Config::overrideTypeComparison(t1, t2, true)
    else
      if t1 instanceof TypedefType and Config::resolveTypedefs()
      then equalTypes(t1.(TypedefType).getBaseType(), t2)
      else
        if t2 instanceof TypedefType and Config::resolveTypedefs()
        then equalTypes(t1, t2.(TypedefType).getBaseType())
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

  /**
   * A type that is either part of the type subset, or that is reachable from a type in the subset.
   */
  private class RelevantType instanceof Type {
    RelevantType() { exists(T t | typeGraph*(t, this)) }

    string toString() { result = this.(Type).toString() }
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
  private predicate equalFunctionTypes(RelevantFunctionType t1, RelevantFunctionType t2) {
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
  private predicate equalTypedefTypes(RelevantTypedefType t1, RelevantTypedefType t2) {
    exists(Boolean baseTypesEqual |
      (baseTypesEqual = true implies equalTypes(t1.getBaseType(), t2.getBaseType())) and
      Config::equalTypedefTypes(t1, t2, baseTypesEqual)
    )
  }
}

module FunctionDeclarationTypeEquivalence<TypeEquivalenceSig Config> {
  predicate equalReturnTypes(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
    TypeEquivalence<Config, FunctionSignatureType>::equalTypes(f1.getType(), f2.getType())
  }

  predicate equalParameterTypes(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
    f1.getDeclaration() = f2.getDeclaration() and
    forall(int i | exists([f1, f2].getParameterDeclarationEntry(i)) |
      TypeEquivalence<Config, FunctionSignatureType>::equalTypes(f1.getParameterDeclarationEntry(i)
            .getType(), f2.getParameterDeclarationEntry(i).getType())
    )
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