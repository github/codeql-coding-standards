/**
 * @id cpp/autosar/declaration-unmodified-object-missing-const-specifier
 * @name A7-1-1: Constexpr or const specifiers shall be used for immutable data declaration
 * @description `Constexpr`/`const` specifiers prevent unintentional data modification for data
 *              intended as immutable.
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

from MutableVariable v, string cond
where
  not isExcluded(v, ConstPackage::declarationUnmodifiedObjectMissingConstSpecifierQuery()) and
  // We handle parameters in a separate query to allow for specific deviations.
  not v instanceof Parameter and
  (
    isNotDirectlyModified(v) and
    not v.getAnAccess().isAddressOfAccessNonConst() and
    notPassedAsArgToNonConstParam(v) and
    notAssignedToNonLocalNonConst(v) and
    if v instanceof MutablePointerOrReferenceVariable
    then
      notUsedAsQualifierForNonConst(v) and
      cond = " points to an object"
    else cond = " is used for an object"
  ) and
  not exists(LambdaExpression lc | lc.getACapture().getField() = v) and
  not v.isFromUninstantiatedTemplate(_)
select v, "Non-constant variable " + v.getName() + cond + " and is not modified."
