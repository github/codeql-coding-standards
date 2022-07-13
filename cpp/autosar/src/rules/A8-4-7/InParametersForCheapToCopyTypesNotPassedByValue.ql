/**
 * @id cpp/autosar/in-parameters-for-cheap-to-copy-types-not-passed-by-value
 * @name A8-4-7: 'in' parameters for 'cheap to copy' types shall be passed by value
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
 * In this rule, we will look cases where a "cheap to copy" type is not passed by value.
 */

from Parameter v, TriviallySmallType t
where
  not isExcluded(v, ClassesPackage::inParametersForCheapToCopyTypesNotPassedByValueQuery()) and
  exists(ReferenceType rt |
    rt = v.getType().stripTopLevelSpecifiers() and
    t = rt.getBaseType()
  ) and
  t.isConst() and
  not exists(CatchBlock cb | cb.getParameter() = v) and
  not exists(CopyConstructor cc | cc.getAParameter() = v) and
  not v.isFromUninstantiatedTemplate(_)
select v,
  "Parameter " + v.getName() + " is the trivially copyable type " + t.getName() +
    " but it is passed by reference instead of by value."
