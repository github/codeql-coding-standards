import cpp

/**
 * A candidate to be a variably length array type (VLA).
 *
 * This class represents a candidate only, for a few reasons.
 *
 * Firstly, the `ArrayType` class does not know when it has variable size, so
 * this class matches all array types with unknown size, including `x[]` which
 * is not a VLA. To determine the difference, we must compare locations between
 * where * these types are declared, and the location of `VlaDecl`s etc.
 *
 * Secondly, function parameters of array type are adjusted into pointers. This
 * means that while a parameter type can be a `CandidateVlaType`, that
 * parameter is not a VLA.
 */
class CandidateVlaType extends ArrayType {
  CandidateVlaType() { not hasArraySize() }

  Type getVariableBaseType() { result = this.getBaseType() }
}

/**
 * A type that is a variably modified type (VMT) if it does not undergo
 * parameter type adjustment.
 *
 * A variably modified type is a VLA type, or a type containing a VMT type, for
 * instance, a pointer to a VLA or a pointer to a pointer to a VLA.
 *
 * Function parameters and function type parameters of type `T[]` are adjusted
 * to type `T*`, which can turn VMTs into non-VMTs. To check if a parameter
 * type is a VMT, use `VariablyModifiedTypeIfAdjusted`.
 */
class VariablyModifiedTypeIfUnadjusted extends Type {
  CandidateVlaType innerVlaType;

  VariablyModifiedTypeIfUnadjusted() {
    // Take care that `int[x][y]` only matches for `innerVlaType = int[y]`.
    if this instanceof CandidateVlaType
    then innerVlaType = this
    else innerVlaType = this.(NoAdjustmentVariablyModifiedType).getInnerVlaType()
  }

  CandidateVlaType getInnerVlaType() { result = innerVlaType }
}

/**
 * A type that is a variably modified type (VMT) if it undergoes parameter type
 * adjustment.
 *
 * A variably modified type is a VLA type, or a type containing a VMT type, for
 * instance, a pointer to a VLA or a pointer to a pointer to a VLA.
 *
 * Function parameters and function type parameters of type `T[]` are adjusted
 * to type `T*`, which can turn VMTs into non-VMTs. To check if a non-parameter
 * type (for instance, the type of a local variable) is a VMT, use
 * `VariablyModifiedTypeIfUnadjusted`.
 */
class VariablyModifiedTypeIfAdjusted extends Type {
  CandidateVlaType innerVlaType;

  VariablyModifiedTypeIfAdjusted() {
    innerVlaType = this.(ParameterAdjustedVariablyModifiedType).getInnerVlaType()
    or
    innerVlaType = this.(NoAdjustmentVariablyModifiedType).getInnerVlaType()
  }

  CandidateVlaType getInnerVlaType() { result = innerVlaType }
}

/**
 * A variably modified type candidate which is unaffected by parameter type
 * adjustment (from `T[]` to `*T`).
 *
 * Parameter adjustment (from `T[]` to `*T`) occurs on all function parameter
 * types for exactly one level of depth.
 *
 * A variably-modified type (VMT) is a type which includes an inner type that is
 * a VLA type. That is to say, a pointer to a VLA is a VMT, and a pointer to a
 * VMT is a VMT.
 *
 * Note: This class does *not* match all VLA types. While VLA types *are* VMTs,
 * VMTs can be parameter-adjusted to pointers, which are not VLA types. This
 * class *will* match multidimensional VLAs, as those are adjusted to pointers
 * to VLAs, and pointers to VLAs are VMTs.
 */
class NoAdjustmentVariablyModifiedType extends Type {
  CandidateVlaType vlaType;

  NoAdjustmentVariablyModifiedType() {
    exists(Type innerType |
      (
        innerType = this.(PointerType).getBaseType()
        or
        innerType = this.(ArrayType).getBaseType()
        or
        innerType = this.(RoutineType).getReturnType()
        or
        innerType = this.(RoutineType).getAParameterType()
        or
        innerType = this.(FunctionPointerType).getReturnType()
        or
        innerType = this.(TypedefType).getBaseType()
        or
        innerType = this.(SpecifiedType).getBaseType()
      ) and
      vlaType = innerType.(VariablyModifiedTypeIfUnadjusted).getInnerVlaType()
    )
    or
    vlaType =
      this.(FunctionPointerType)
          .getAParameterType()
          .(VariablyModifiedTypeIfAdjusted)
          .getInnerVlaType()
    or
    vlaType =
      this.(RoutineType).getAParameterType().(VariablyModifiedTypeIfAdjusted).getInnerVlaType()
  }

  CandidateVlaType getInnerVlaType() { result = vlaType }
}

/**
 * An array type that adjusts to a variably-modified type (a type which is or
 * contains a VLA type) when it is a parameter type.
 *
 * A variably-modified type (VMT) is a VLA type or a type which has an inner type
 * that is a VMT type, for instance, a pointer to a VLA type.
 *
 * Parameter adjustment occurs on all function parameter types, changing type
 * `T[]` to `*T` for exactly one level of depth. Therefore, a VLA type will not
 * be a VLA type/VMT after parameter adjustment, unless it is an array of VMTs,
 * such that it parameter adjustment produces a pointer to a VMT.
 */
class ParameterAdjustedVariablyModifiedType extends ArrayType {
  CandidateVlaType innerVlaType;

  ParameterAdjustedVariablyModifiedType() {
    innerVlaType = getBaseType().(VariablyModifiedTypeIfUnadjusted).getInnerVlaType()
  }

  CandidateVlaType getInnerVlaType() { result = innerVlaType }
}
