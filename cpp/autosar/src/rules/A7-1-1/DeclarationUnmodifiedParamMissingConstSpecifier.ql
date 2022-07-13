/**
 * @id cpp/autosar/declaration-unmodified-param-missing-const-specifier
 * @name A7-1-1: Constexpr or const specifiers shall be used for immutable parameter usage
 * @description `Constexpr`/`const` specifiers prevent unintentional data modification for
 *              parameters intended as immutable.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a7-1-1
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.ConstHelpers

from FunctionParameter v, string cond
where
  not isExcluded(v, ConstPackage::declarationUnmodifiedParamMissingConstSpecifierQuery()) and
  v instanceof AccessedParameter and
  (
    isNotDirectlyModified(v) and
    not v.getAnAccess().isAddressOfAccessNonConst() and
    notPassedAsArgToNonConstParam(v) and
    notAssignedToNonLocalNonConst(v) and
    if v instanceof NonConstPointerorReferenceParameter
    then
      notUsedAsQualifierForNonConst(v) and
      notReturnedFromNonConstFunction(v) and
      cond = " points to an object"
    else cond = " is used for an object"
  ) and
  //exclude already consts
  if v.getType() instanceof ReferenceType
  then not v.getType().(DerivedType).getBaseType+().isConst()
  else not v.getType().isConst()
select v, "Non-constant parameter " + v.getName() + cond + " and is not modified."
