/**
 * A library for utility classes related to the built-in type rules in MISRA C++ 2023 (Section 4.7.0).
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Call
import codingstandards.cpp.Type
import codingstandards.cpp.types.CanonicalTypes

module MisraCpp23BuiltInTypes {
  /**
   * A MISRA C++ 2023 type category.
   */
  newtype TypeCategory =
    IntegralTypeCategory() or
    FloatingPointTypeCategory() or
    CharacterTypeCategory() or
    OtherTypeCategory()

  /**
   * Gets the type category of a built-in type.
   *
   * This does not apply the rules related to stripping specifiers or typedefs, or references.
   */
  private TypeCategory getBuiltInTypeCategory(BuiltInType t) {
    (
      t instanceof PlainCharType or
      t instanceof WideCharType or
      t instanceof Char16Type or
      t instanceof Char32Type or
      t instanceof Char8Type
    ) and
    result = CharacterTypeCategory()
    or
    (
      // The 5 standard integral types, covering both signed/unsigned variants
      // Explicitly list the signed/unsigned `char` to avoid capturing plain `char`, which is of character type category
      t instanceof SignedCharType or
      t instanceof UnsignedCharType or
      t instanceof ShortType or
      t instanceof IntType or
      t instanceof LongType or
      t instanceof LongLongType
    ) and
    result = IntegralTypeCategory()
    or
    (
      t instanceof FloatType or
      t instanceof DoubleType or
      t instanceof LongDoubleType
    ) and
    result = FloatingPointTypeCategory()
    or
    (
      t instanceof BoolType or
      t instanceof VoidType or
      t instanceof NullPointerType
    ) and
    result = OtherTypeCategory()
  }

  /**
   * Gets the built-in type of a type, if it is a built-in type.
   *
   * This function will strip specifiers and typedefs to get the underlying built-in type.
   */
  private BuiltInType getBuiltInType(Type t) {
    // Get the built-in type of a type, if it is a built-in type
    result = t
    or
    // Strip specifiers and typedefs to get the built-in type
    result = getBuiltInType(t.getUnspecifiedType())
    or
    // For reference types, get the base type and then the built-in type
    result = getBuiltInType(t.(ReferenceType).getBaseType())
    or
    // For enum types, get the explicit underlying type and then the built-in type
    result = getBuiltInType(t.(Enum).getExplicitUnderlyingType())
  }

  /**
   * The signedness of a MISRA C++ 2023 numeric type.
   */
  newtype Signedness =
    Signed() or
    Unsigned()

  /**
   * A `Type` which is considered to be a built-in type by MISRA.
   *
   * It differs from `BuiltInType` in that includes:
   *  - Built in types with specifiers (e.g., `const`, `volatile`, `restrict`).
   *  - Typedefs to built in types
   *  - References to built in types
   *  - Enum types with an explicit underlying type that is a built-in type.
   *
   * Note: this does not extend `Type` directly, to prevent accidental use of `getSize()`, which
   * returns the "wrong" size for e.g. reference types.
   */
  class MisraBuiltInType extends Element {
    // The built in type underlying this MISRA built in type
    BuiltInType builtInType;

    MisraBuiltInType() { builtInType = getBuiltInType(this) }

    private BuiltInType getBuiltInType() { result = builtInType }

    /** Gets the size of the underlying built in type. */
    int getBuiltInSize() { result = builtInType.getSize() }

    TypeCategory getTypeCategory() { result = getBuiltInTypeCategory(builtInType) }

    predicate isSameType(MisraBuiltInType other) { this.getBuiltInType() = other.getBuiltInType() }

    string getName() { result = this.(Type).getName() }
  }

  class CharacterType extends MisraBuiltInType {
    CharacterType() {
      // A type whose type category is character
      getBuiltInTypeCategory(builtInType) = CharacterTypeCategory()
    }
  }

  /**
   * A MISRA C++ 2023 numeric type is a type that represents a number, either an integral or a floating-point.
   *
   * In addition to the basic integral and floating-point types, it includes:
   * - Enum types with an explicit underlying type that is a numeric type.
   * - Typedef'd types that are numeric types.
   * - Numeric types with specifiers (e.g., `const`, `volatile`, `restrict`).
   */
  class NumericType extends MisraBuiltInType {
    NumericType() {
      // A type whose type category is either integral or a floating-point
      getBuiltInTypeCategory(builtInType) =
        [IntegralTypeCategory().(TypeCategory), FloatingPointTypeCategory()]
    }

    Signedness getSignedness() {
      if builtInType.(IntegralType).isUnsigned() then result = Unsigned() else result = Signed()
    }

    /**
     * Gets the integeral upper bound of the numeric type, if it represents an integer type.
     */
    QlBuiltins::BigInt getIntegralUpperBound() { integralTypeBounds(builtInType, _, result) }

    /**
     * Gets the integeral lower bound of the numeric type, if it represents an integer type.
     */
    QlBuiltins::BigInt getIntegralLowerBound() { integralTypeBounds(builtInType, result, _) }
  }

  predicate isSignedType(NumericType t) { t.getSignedness() = Signed() }

  predicate isUnsignedType(NumericType t) { t.getSignedness() = Unsigned() }

  /**
   * A canonical integer type for each unique size and signedness combination.
   *
   * Where multiple canonical arithmetic types exist for a given size/signedness combination, we
   * prefer the type with the shortest name.
   */
  class CanonicalIntegerNumericType extends NumericType {
    CanonicalIntegerNumericType() {
      // Where multiple types exist with the same size and signedness, prefer shorter names - mainly
      // to disambiguate between `unsigned long` and `unsigned long long` on platforms where they
      // are the same size
      this.(CanonicalIntegralType).isMinimal()
      or
      // `signed char` is not considered a canonical type (`char` is), but `char` is not a MISRA numeric
      // type, so we need to reintroduce `signed char` here.
      this instanceof SignedCharType
    }
  }

  predicate isAssignment(Expr source, Type targetType, string context) {
    exists(Expr preConversionAssignment |
      isPreConversionAssignment(preConversionAssignment, targetType, context) and
      preConversionAssignment.getExplicitlyConverted() = source
    )
  }

  predicate isPreConversionAssignment(Expr source, Type targetType, string context) {
    if isAssignedToBitfield(source, _)
    then
      // For the MISRA type rules we treat bit fields as a special case
      exists(BitField bf |
        isAssignedToBitfield(source, bf) and
        targetType = getBitFieldType(bf) and
        context = "assignment to bitfield"
      )
    else (
      // Assignment expression (which excludes compound assignments)
      exists(AssignExpr assign |
        assign.getRValue() = source and
        context = "assignment"
      |
        exists(Type t | t = assign.getLValue().getType() |
          // Unwrap PointerToMemberType e.g `l1.*l2 = x;`
          if t instanceof PointerToMemberType
          then targetType = t.(PointerToMemberType).getBaseType()
          else targetType = t
        )
      )
      or
      // Variable initialization
      exists(Variable v, Initializer init |
        init.getExpr() = source and
        v.getInitializer() = init and
        context = "initialization"
      |
        targetType = v.getType()
      )
      or
      exists(ConstructorFieldInit fi |
        fi.getExpr() = source and
        context = "constructor field initialization"
      |
        targetType = fi.getTarget().getType()
      )
      or
      // Passing a function parameter by value
      exists(Call call, int i |
        call.getArgument(i) = source and
        not targetType.stripTopLevelSpecifiers() instanceof ReferenceType and
        context = "function argument"
      |
        // A regular function call
        targetType = call.getTarget().getParameter(i).getType()
        or
        // A function call where the argument is passed as varargs
        call.getTarget().getNumberOfParameters() <= i and
        // The rule states that the type should match the "adjusted" type of the argument
        targetType = source.getFullyConverted().getType()
        or
        // An expression call - get the function type, then the parameter type
        targetType = getExprCallFunctionType(call).getParameterType(i)
      )
      or
      // Return statement
      exists(ReturnStmt ret, Function f |
        ret.getExpr() = source and
        ret.getEnclosingFunction() = f and
        targetType = f.getType() and
        not targetType.stripTopLevelSpecifiers() instanceof ReferenceType and
        context = "return"
      )
      or
      // Switch case
      exists(SwitchCase case, SwitchStmt switch |
        case.getExpr() = source and
        case.getSwitchStmt() = switch and
        context = "switch case"
      |
        // Get the type of the switch expression, which is the type of the case expression
        targetType = switch.getExpr().getFullyConverted().getType()
      )
      or
      // Class aggregate literal initialization
      exists(ClassAggregateLiteral al, Field f |
        source = al.getAFieldExpr(f) and
        context = "class aggregate literal"
      |
        targetType = f.getType()
      )
      or
      // Array or vector aggregate literal initialization
      exists(ArrayOrVectorAggregateLiteral vl |
        source = vl.getAnElementExpr(_) and
        targetType = vl.getElementType() and
        context = "array or vector aggregate literal"
      )
    )
  }

  /**
   * Gets the smallest integral type that can hold the value of a bit field.
   *
   * The type is determined by the signedness of the bit field and the number of bits.
   */
  CanonicalIntegerNumericType getBitFieldType(BitField bf) {
    exists(NumericType bitfieldActualType |
      bitfieldActualType = bf.getType() and
      // Integral type with the same signedness as the bit field, and big enough to hold the bit field value
      result.getSignedness() = bitfieldActualType.getSignedness() and
      result.getBuiltInSize() * 8 >= bf.getNumBits() and
      // No smaller integral type can hold the bit field value
      not exists(CanonicalIntegerNumericType other |
        other.getBuiltInSize() * 8 >= bf.getNumBits() and
        other.getSignedness() = result.getSignedness()
      |
        other.getBuiltInSize() < result.getBuiltInSize()
      )
    )
  }

  /**
   * Holds if the `source` expression is "assigned" to a bit field per MISRA C++ 2023.
   */
  predicate isAssignedToBitfield(Expr source, BitField bf) {
    source = bf.getAnAssignedValue().getExplicitlyConverted()
    or
    exists(SwitchStmt switch, SwitchCase case |
      bf = switch.getExpr().(FieldAccess).getTarget() and
      source = case.getExpr()
    )
  }
}
