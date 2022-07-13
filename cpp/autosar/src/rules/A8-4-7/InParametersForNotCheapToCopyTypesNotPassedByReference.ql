/**
 * @id cpp/autosar/in-parameters-for-not-cheap-to-copy-types-not-passed-by-reference
 * @name A8-4-7: 'in' parameters for not 'cheap to copy' types shall be passed by reference
 * @description One purpose of passing an argument by value is to document that the argument won't
 *              be modified. Copying the value (instead of passing by reference to const) also
 *              ensures that no indirection is needed in the function body to access the value.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a8-4-7
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import TriviallySmallType
import codingstandards.cpp.CommonTypes as CommonTypes

/*
 * For the purposes of this rule, "cheap to copy" is defined as a trivially copyable type that is no
 * longer than two words.
 *
 * In this rule, we will look cases where a not "cheap to copy" type is not passed by reference.
 */

from Parameter v
where
  not isExcluded(v, ClassesPackage::inParametersForNotCheapToCopyTypesNotPassedByReferenceQuery()) and
  not v.getType() instanceof TriviallySmallType and
  not v.getType().getUnderlyingType() instanceof ReferenceType and
  not exists(CatchBlock cb | cb.getParameter() = v) and
  not v.isFromUninstantiatedTemplate(_)
select v,
  "Parameter " + v.getName() +
    " is the trivially non-copyable type $@ but it is passed by value instead of by reference.",
  v.getType(), v.getType().getName()
