import cpp

/**
 * A declaration involving a variably-modified type.
 *
 * Note, this holds for both VLA variable and VLA typedefs.
 */
class VmtDeclarationEntry extends DeclarationEntry {
  Expr sizeExpr;
  CandidateVlaType vlaType;
  // `before` and `after` are captured for debugging, see doc comment for
  // `declarationSubsumes`.
  Location before;
  Location after;

  VmtDeclarationEntry() {
    // Most of this library looks for candidate VLA types, by looking for arrays
    // without a size. These may or may not be VLA types. To confirm an a
    // candidate type is really a VLA type, we check that the location of the
    // declaration subsumes a `VlaDimensionStmt` which indicates a real VLA.
    sizeExpr = any(VlaDimensionStmt vla).getDimensionExpr() and
    declarationSubsumes(this, sizeExpr.getLocation(), before, after) and
    (
      if this instanceof ParameterDeclarationEntry
      then vlaType = this.getType().(VariablyModifiedTypeIfAdjusted).getInnerVlaType()
      else vlaType = this.getType().(VariablyModifiedTypeIfUnadjusted).getInnerVlaType()
    )
  }

  Expr getSizeExpr() { result = sizeExpr }

  CandidateVlaType getVlaType() { result = vlaType }

  /* VLAs may occur in macros, and result in duplication that messes up our analysis. */
  predicate appearsDuplicated() {
    exists(VmtDeclarationEntry other |
      other != this and
      other.getSizeExpr() = getSizeExpr()
    )
  }
}

/**
 * Check that the declaration entry, which may be a parameter or a variable
 * etc., seems to subsume the location of `inner`, including the declaration
 * type text.
 *
 * The location of the `DeclarationEntry` itself points to the _identifier_
 * that is declared. This range will not include the type of the declaration.
 *
 * For parameters, the `before` and `end` `Location` objects will be
 * constrained to the closest earlier element (parameter or function body),
 * these values can therefore be captured and inspected for debugging.
 *
 * For declarations which occur in statements, the `before` and `end`
 * `Location` objects will be both constrained to be equal, and equal to,
 * the `Location` of the containing `DeclStmt`.
 */
private predicate declarationSubsumes(
  DeclarationEntry entry, Location inner, Location before, Location after
) {
  inner.getFile() = entry.getLocation().getFile() and
  (
    exists(ParameterDeclarationEntry param, FunctionDeclarationEntry func, int i |
      param = entry and
      func = param.getFunctionDeclarationEntry() and
      func.getParameterDeclarationEntry(i) = param and
      before = entry.getLocation() and
      (
        after = func.getParameterDeclarationEntry(i + 1).getLocation()
        or
        not exists(ParameterDeclarationEntry afterParam |
          afterParam = func.getParameterDeclarationEntry(i + 1)
        ) and
        after = func.getBlock().getLocation()
      )
    ) and
    before.isBefore(inner, _) and
    inner.isBefore(after, _)
    or
    exists(DeclStmt s |
      s.getADeclaration() = entry.getDeclaration() and
      before = s.getLocation() and
      after = before and
      before.subsumes(inner)
    )
  )
}

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
        innerType = this.(DerivedType).getBaseType()
        or
        innerType = this.(RoutineType).getReturnType()
        or
        innerType = this.(FunctionPointerType).getReturnType()
        or
        innerType = this.(TypedefType).getBaseType()
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
