/**
 * @id c/misra/pointers-to-variably-modified-array-types-used
 * @name RULE-18-10: Pointers to variably-modified array types shall not be used
 * @description Pointers to variably-modified array types shall not be used, as these pointer types
 *              are frequently incompatible with other fixed or variably sized arrays, resulting in
 *              undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-18-10
 *       external/misra/c/2012/amendment4
 *       correctness
 *       security
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.VariablyModifiedTypes

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
predicate declarationSubsumes(
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
 * A declaration involving a pointer to a variably-modified type.
 */
class InvalidDeclaration extends DeclarationEntry {
  Expr sizeExpr;
  CandidateVlaType vlaType;

  // `before` and `after` are captured for debugging, see doc comment for
  // `declarationSubsumes`.
  Location before;
  Location after;

  InvalidDeclaration() {
    sizeExpr = any(VlaDimensionStmt vla).getDimensionExpr() and
    declarationSubsumes(this, sizeExpr.getLocation(), before, after) and
    (
      if this instanceof ParameterDeclarationEntry
      then vlaType = this.getType().(VariablyModifiedTypeIfAdjusted).getInnerVlaType()
      else vlaType = this.getType().(VariablyModifiedTypeIfUnadjusted).getInnerVlaType()
    )
    // Capture only pointers to VLA types, not raw VLA types.
    and not vlaType = this.getType()
  }

  Expr getSizeExpr() { result = sizeExpr }

  CandidateVlaType getVlaType() { result = vlaType }
}

from InvalidDeclaration v, string declstr, string adjuststr, string relationstr
where
  not isExcluded(v, InvalidMemory3Package::pointersToVariablyModifiedArrayTypesUsedQuery()) and
  (
    if v instanceof ParameterDeclarationEntry
    then declstr = "Parameter "
    else
      if v instanceof VariableDeclarationEntry
      then declstr = "Variable "
      else declstr = "Declaration "
  ) and
  (
    if
      v instanceof ParameterDeclarationEntry and
      v.getType() instanceof ParameterAdjustedVariablyModifiedType
    then adjuststr = "adjusted to"
    else adjuststr = "declared with"
  ) and
  (
    if v.getType().(PointerType).getBaseType() instanceof CandidateVlaType
    then relationstr = "pointer to"
    else relationstr = "with inner"
  )
select v,
  declstr + v.getName() + " is " + adjuststr + " variably-modified type, " + relationstr +
    " variable length array of non constant size $@ and element type '" +
    v.getVlaType().getVariableBaseType() + "'", v.getSizeExpr(), v.getSizeExpr().toString()
