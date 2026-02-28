private import cpp
private import qtil.Qtil
private import codingstandards.cpp.types.Specifiers
private import codeql.util.Boolean

Type typeResolvesToTypeStep(Type type) {
  result = type.(Decltype).getBaseType()
  or
  result = type.(TypedefType).getBaseType()
}

module PointerTo<Qtil::Signature<Type>::Type PointeeType> {
  /**
   * A pointer type that points to a type that resolves to the module's `PointeeType` type parameter.
   */
  class Type extends Qtil::Final<PointerType>::Type {
    Type() { getBaseType() instanceof PointeeType }
  }
}

module ReferenceOf<Qtil::Signature<Type>::Type ReferencedType> {
  /**
   * A reference type that refers to a type that resolves to the module's `ReferencedType` type
   * parameter.
   */
  class Type extends Qtil::Final<ReferenceType>::Type {
    Type() { getBaseType() instanceof ReferencedType }
  }
}

/**
 * A module for handling complex type resolution in c++, such as a decltype of a const typedef
 * of a struct type, which resolves to a const struct type.
 *
 * Basic usage:
 * - `ResolvesTo<ClassType>::Exactly` is the set of class types, and typedefs/decltypes that resolve
 *   to class types exactly (without specifiers).
 * - `resolvedType.resolve()` gets the fully resolved class type for the above.
 * - `ResolvesTo<ClassType>::Specified` is the set of types that resolve to a specified class type.
 * - `ResolvesTo<ClassType>::Ref` is the set of types that resolve to a reference to a class type.
 * - `ResolvesTo<ClassType>::CvConst` is the set of types that resolve to a const class type.
 * - `ResolvesTo<ClassType>::IgnoringSpecifiers` is the set of types that resolve to a class type
 *    ignoring specifiers.
 * - `ResolvesTo<ClassType>::ExactlyOrRef` is the set of types that resolve to a class type and
 *    unwraps references.
 *
 * These module classes are preferred to the member predicates on `Type` such as `resolveTypedefs`,
 * `stripSpecifiers`, `getUnderlyingType()`, etc, for the following reasons:
 * - Hopefully the API is clearer and easier to use correctly.
 * - Unlike `resolveTypedefs`, these classes can find types that resolve to other typedefs (via
 *   `ResolvesType<SomeTypedefType>::Exactly` etc.), instead of always resolving all typedefs.
 * - The member predicates on `Type` have cases with no result. For instance, if there's a const
 *   typedef `const T = F`, but `const F` is never explicitly written in the code, then there is no
 *   matching extracted `Type` for `resolveTypedefs` to return, and it will have no result.
 */
module ResolvesTo<Qtil::Signature<Type>::Type ResolvedType> {
  private import cpp as cpp

  final class CppType = cpp::Type;

  /**
   * A type that resolves exactly to the module's `ResolvedType` type parameter.
   *
   * For example, `ResolvesTo<FooType>::Type` is the set of all `FooType`s and types that resolve
   * (through typedefs * and/or decltypes) to `FooType`s. This does _not_ include types that resolve
   * to a const `FooType` (though `FooType` itself may be const). To perform type resolution and
   * check or strip specifiers, see module classes `IgnoringSpecifiers`, `Specified`, `Const`, etc.
   *
   * ```
   * // Example `ResolvesTo<FooType>::Exactly` types:
   * FooType f;          // matches (a FooType)
   * decltype(f);        // matches (a decltype of FooType)
   * typedef FooType FT; // matches (a typedef of FooType)
   * FT f2;              // matches (a typedef of FooType)
   * decltype(f2);       // matches (a decltype of typedef of FooType)
   * typedef FT FT2;     // matches (a typedef of typedef of FooType)
   *
   * // Examples types that are not `ResolvesTo<FooType>::Exactly` types:
   * const FooType cf;  // does not match (specified FooTypes)
   * FooType& rf = f;   // does not match (references to FooTypes)
   * NotFooType nf;     // does not match (non FooTypes)
   * ```
   */
  class Exactly extends CppType {
    ResolvedType resolvedType;

    Exactly() { resolvedType = typeResolvesToTypeStep*(this) }

    ResolvedType resolve() { result = resolvedType }
  }

  /**
   * A type that resolves to a const type that in turn resolves to the module's `ResolvedType` type.
   *
   * For example, `ResolvesTo<FooType>::CvConst` is the set of all const `FooType`s and types that
   * resolve (through typedefs and/or decltypes) to const `FooType`s, including cases involving
   * `const` typedefs, etc.
   *
   * Volatile specifiers are ignored, since const volatile types are still const.
   *
   * For matching both const and non-const types that resolve to `FooType`, see
   * `IgnoringSpecifiers`.
   *
   * ```
   * // Note that this does NOT match `FooType`s that are not const.
   * FooType f;            // does not match (non-const)
   * decltype(f) df;       // does not match (non-const)
   * typedef TF = FooType; // does not match (non-const)
   *
   * // Example `ResolvesTo<FooType>::Const` types:
   * const FooType cf;          // matches (a const FooType)
   * const volatile FooType cf; // matches (a const FooType, volatile is allowed and ignored)
   * decltype(cf);              // matches (a decltype of a const FooType)
   * const decltype(f);         // matches (a const decltype of FooType)
   * const decltype(cf);        // matches (a const decltype of a const FooType)
   * typedef const FooType CFT; // matches (a typedef of const FooType)
   * const TF ctf;              // matches (a const typedef of FooType)
   *
   * // Additional examples types that are not `ResolvesTo<FooType>::Const` types:
   * const FooType &f; // does not match (reference to const FooType)
   * ```
   */
  class CvConst extends Specified {
    CvConst() { getASpecifier() instanceof ConstSpecifier }
  }

  /**
   * A type that resolves to a cv-qualified (or otherwise specified) type that in turn resolves to
   * the module's `ResolvedType` type parameter.
   *
   * For example, `ResolvesTo<FooType>::Specified` is the set of all specified `FooType`s and types
   * that resolve (through typedefs and/or decltypes) to specified `FooType`s, including cases
   * involving `const` and `volatile` typedefs, etc.
   *
   * ```
   * // Note that this does NOT match `FooType`s that are not specified.
   * FooType f;            // does not match (not specified)
   * decltype(f) df;       // does not match (not specified)
   * typedef TF = FooType; // does not match (not specified)
   *
   * // Example `ResolvesTo<FooType>::Specified` types:
   * const FooType cf;           // matches (a const FooType)
   * volatile FooType vf;        // matches (a volatile FooType)
   * const volatile FooType cvf; // matches (a const volatile FooType)
   * decltype(cf);               // matches (a decltype of a const FooType)
   * volatile decltype(f);       // matches (a volatile decltype of FooType)
   * const decltype(vf);         // matches (a const decltype of volatile FooType)
   * const decltype(cf);         // matches (a const decltype of const FooType)
   * typedef const FooType CFT;  // matches (a typedef of const FooType)
   * const TF ctf;               // matches (a const typedef of FooType)
   * volatile TF ctf;            // matches (a volatile typedef of FooType)
   *
   * // Additional examples types that are not `ResolvesTo<FooType>::Specified` types:
   * const FooType &f;      // does not match (reference to const FooType)
   * ```
   */
  class Specified extends CppType {
    ResolvedType resolved;

    Specified() {
      resolved = typeResolvesToTypeStep*(this).(SpecifiedType).getBaseType().(Exactly).resolve()
    }

    ResolvedType resolve() { result = resolved }
  }

  /**
   * A class that resolves to the module's `ResolvedType` type parameter, ignoring specifiers.
   */
  class IgnoringSpecifiers extends CppType {
    ResolvedType resolved;

    IgnoringSpecifiers() {
      resolved = this.(Specified).resolve()
      or
      resolved = this.(Exactly).resolve()
    }

    ResolvedType resolve() { result = resolved }
  }

  /**
   * A type that resolves to a reference that resolves to the module's `ResolvedType` type
   * parameter.
   *
   * For example, `ResolvesTo<FooType>::Ref` is the set of all references to `FooType`s and types
   * that resolve (through typedefs and/or decltypes) to references to `FooType`s.
   *
   * ```
   * // Example `ResolvesTo<FooType>::Ref` types:
   * FooType &f;          // matches (a reference to FooType)
   * decltype(f);         // matches (a decltype of reference to FooType)
   * typedef FooType &FT; // matches (a typedef of ref to FooType)
   * FT f2;               // matches (a typedef of ref to FooType)
   * decltype(f2);        // matches (a decltype of typedef of ref to FooType)
   * typedef FT FT2;      // matches (a typedef of typedef of ref to FooType)
   *
   * // Examples types that are not `ResolvesTo<FooType>::Ref` types:
   * const FooType &cf;  // does not match (specified references to FooTypes)
   * FooType rf = f;     // does not match (non-rerefence FooTypes)
   * NotFooType &nf;     // does not match (non FooTypes)
   * ```
   */
  class Ref extends CppType {
    ResolvedType resolved;

    Ref() {
      // Note that the extractor appears to perform reference collapsing, so cases like
      // `const T& &` are treated as `const T&`.
      resolved = typeResolvesToTypeStep*(this).(ReferenceType).getBaseType().(Exactly).resolve()
    }

    ResolvedType resolve() { result = resolved }
  }

  /**
   * A type that resolves to a const reference of (or reference to const of) the module's
   * `ResolvedType` type parameter.
   *
   * For example, `ResolvesTo<FooType>::CvConstRef` is the set of all const references to `FooType`s
   * and types that resolve (through typedefs and/or decltypes) to const references to `FooType`s.
   *
   * Volatile specifiers are ignored, since const volatile types are still const.
   *
   * ```
   * FooType &f;         // does not match (not const)
   * const FooType f;    // does not match (not a reference)
   *
   * // Example `ResolvesTo<FooType>::CvConstRef` types:
   * const FooType &cf;          // matches (a const reference to FooType)
   * const volatile FooType &cf; // matches (a const reference to FooType, volatile is ignored)
   * const decltype(f) cdf;      // matches (a const decltype of reference to FooType)
   * decltype(f)& dcf;           // matches (a decltype of const reference to FooType)
   * typedef const FooType &CFT; // matches (a typedef of const ref to FooType)
   * const CFT ctf;              // matches due to const collapse
   * CFT &ctf;                   // matches due to reference collapse
   * ```
   */
  class CvConstRef extends CppType {
    ResolvedType resolved;

    CvConstRef() {
      exists(ReferenceType refType |
        // A type can be a reference to const, but a const type cannot contain a reference.
        // Therefore, we only need to find reference types that resolve to const types.
        // Note that the extractor appears to perform reference collapsing, so cases like
        // `const T& &` are treated as `const T&`.
        refType = typeResolvesToTypeStep*(this) and
        resolved = refType.getBaseType().(CvConst).resolve()
      )
    }

    ResolvedType resolve() { result = resolved }
  }

  /**
   * A type that resolves to either a reference that resolves to the module's `ResolvedType` type
   * parameter, or exactly to the `ResolvedType`.
   */
  class ExactlyOrRef extends CppType {
    ResolvedType resolved;

    ExactlyOrRef() {
      resolved = this.(Ref).resolve()
      or
      resolved = this.(Exactly).resolve()
    }

    ResolvedType resolve() { result = resolved }
  }
}
